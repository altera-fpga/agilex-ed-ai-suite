// Copyright 2020-2024 Intel Corporation.
//
// This software and the related documents are Intel copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Intel's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

// This MMD object can only support one inference request.
// TODO: factor this system-console MMD into its own "aocl" layer.
//       The hostless-ED runtime should use the generic MMD interface
//       to access the "aocl" layer

#include "mmd_wrapper.h"
#include "dla_dma_constants.h"  // DLA_DMA_CSR_OFFSET_***

#include <cassert>    // assert
#include <cstddef>    // size_t
#include <iostream>   // std::cerr
#include <stdexcept>  // std::runtime_error
#include <string>     // std::string

#include <boost/process/v1/pipe.hpp>
#include <boost/process/v1/child.hpp>
#include <boost/process/v1/io.hpp>
#include <boost/process/v1/search_path.hpp>
#include <boost/process/v1/environment.hpp>
#include <boost/process/v1/error.hpp>
#include <boost/filesystem.hpp>
#include <boost/format.hpp>
#include <boost/filesystem/fstream.hpp>
#include <string>
#include <iostream>
#include <string>
#include <cstdio>
#include <sstream>
#include <ostream>
#include <chrono>
#include <thread>
#include <mutex>
#include <fstream> // std::ofstream

#define xstr(s) _str(s)
#define _str(s)  #s

#define DLA_SYSTEM_CONSOLE_TIMEOUT_MS 80000

// All board variants must obey the CoreDLA CSR spec, which says that all access must be
// - 32 bits in size
// - address must be 4 byte aligned
// - within the address range, CSR size is 2048 bytes
constexpr uint64_t DLA_CSR_ALIGNMENT = 4;
constexpr uint64_t DLA_CSR_SIZE = 2048;
namespace bp = boost::process::v1; //we will assume this for all further examples

constexpr auto max_size = std::numeric_limits<std::streamsize>::max();

static boost::filesystem::path temp_file_path;
static boost::filesystem::path tcl_file_path;
static boost::filesystem::path sof_file_path;
static uint32_t enable_pmon;
static bool     preserve_temp_files;

const uint32_t DLA_CSR_BASE_ADDRESS = 0x80000000;
const uint32_t DLA_DDR_BASE_ADDRESS = 0x0;
const uint32_t DLA_HW_TIMER_BASE_ADDRESS = 0x80000800;


static bp::opstream in;
static bp::ipstream out;
static bp::child subprocess;

// One mutex for all system-console calls
static std::mutex syscon_mutex;
static unsigned int timeout_ms;

// CSR logger file object
static std::ofstream loggerFile;
static const std::string loggerFileName = "csr_log.txt";
static MmdLogLevel csrLogLevel;

static int capture_till_prompt(bp::ipstream& out, std::ostream& capture)
{
  std::array<char, 4096> line_buffer;
  if (out.fail()) {
    std::cout << "EOF" << std::endl;
    return 1;
  }

  // Polling for response until timeout
  bool timedOut = false;
  auto timeoutDuration = std::chrono::milliseconds(timeout_ms);
  std::chrono::time_point<std::chrono::system_clock> captureEndingTime =
        std::chrono::system_clock::now() + timeoutDuration;
  do {
    out.clear();
    out.getline(&line_buffer[0], (std::streamsize)line_buffer.size(), '%');
    capture.write(&line_buffer[0], out.gcount());
    // If out.getline fills the line buffer without encountering the delimiter
    // then the failbit of out will be set, causing out.fail() to return true.
    // bp::ipstream indirectly inherits std::ios_base::iostate, which defines failbit/badbit
    if (std::chrono::system_clock::now() > captureEndingTime) {
        timedOut = true;
        break;
    }
  } while (out.fail() && out.gcount() == line_buffer.size()-1);

  if (out.fail()) {
    std::cout << "EOF" << std::endl;
    return 1;
  }

  if (timedOut) {
    std::cout << "Timeout while waiting for system console response. "
              << "Current timeout threshold is "
              << timeout_ms
              << " ms. Try setting macro DLA_SYSTEM_CONSOLE_TIMEOUT_MS in "
              << "runtime/coredla_device/mmd/system_console/mmd_wrapper.cpp to a higher value."
              << std::endl << std::flush;
    return 1;
  }
  return 0;
}

static int wait_for_prompt(bp::ipstream& out)
{
  // Dump output to stream s1, but we don't actually print it.
  std::basic_stringstream<char> s1;
  return capture_till_prompt(out, s1);
}

std::string remove_non_alphanumeric(const std::string& input) {
  std::string result = input;
  result.erase(std::remove_if(result.begin(), result.end(), [](unsigned char c) {
   return !std::isalnum(c);
  }), result.end());
  return result;
}

static void send_command(bp::opstream& in, std::string command)
{
  in << command << "\n";
  in.flush();
  if (loggerFile.is_open() && csrLogLevel > MmdLogLevel::DISABLE) {
    loggerFile << command << std::endl;
    loggerFile << std::flush;
  }
}

static void write_to_csr(bp::opstream& in, bp::ipstream& out, uint32_t addr, uint32_t data) {
  std::lock_guard<std::mutex> lock{syscon_mutex};
  addr += DLA_CSR_BASE_ADDRESS;
  send_command(in, "master_write_32 $::g_dla_csr_service " + str( boost::format("0x%|08x| 0x%|08x|") % addr % data));
  if (0 != wait_for_prompt(out))
  {
    throw std::runtime_error("Unexpected EOF");
  }
}

static uint32_t read_from_csr(bp::opstream& in, bp::ipstream& out, uint32_t addr) {
  std::lock_guard<std::mutex> lock{syscon_mutex};
  uint32_t data;
  addr += DLA_CSR_BASE_ADDRESS;
  send_command(in, "master_read_32 $::g_dla_csr_service " + str( boost::format("0x%|08x|") % addr ) + " 1");
  std::basic_stringstream<char> s1;
  std::string captured;
  do {
    if (0 != capture_till_prompt(out, s1))
    {
      throw std::runtime_error("Unexpected EOF");
    }
    captured = s1.str();
  } while (std::all_of(captured.begin(), captured.end(), [](unsigned char c){return (std::isspace(c) || std::iscntrl(c));}));
  std::string trimmed = remove_non_alphanumeric(captured);
  data = std::stoul(trimmed, nullptr, 16);
  if (loggerFile.is_open() && csrLogLevel > MmdLogLevel::DISABLE) {
    loggerFile << "Read back: " << data << std::endl;
    loggerFile << std::flush;
  }
  return data;
}

static void read_from_ddr(bp::opstream& in, bp::ipstream& out, uint64_t addr, uint64_t length, void* data)
{
  std::lock_guard<std::mutex> lock{syscon_mutex};
  if (data == nullptr)
  {
    throw std::runtime_error("null data");
  }
  boost::filesystem::path temp_file_name = boost::filesystem::unique_path();
  boost::filesystem::path temppath = temp_file_path / temp_file_name;
  send_command(in, "master_read_to_file $::g_emif_ddr_service " + temppath.generic_string() + str( boost::format(" 0x%|08x| 0x%|08x|") % addr % length ) );
  if (0 != wait_for_prompt(out)) {
    throw std::runtime_error("Unexpected EOF");
  }
  boost::filesystem::ifstream ifs(temppath, std::ios::in | std::ios::binary);
  ifs.read(static_cast<char *>(data), length);
  ifs.close();

  if (!preserve_temp_files) {
    try {
          boost::filesystem::remove(temppath);
        } catch (const boost::filesystem::filesystem_error& ex) {
          std::cerr << "Error removing file: " << ex.what() << std::endl;
    }
  }
}

static void write_to_ddr(bp::opstream& in, bp::ipstream& out, uint64_t addr, uint64_t length, const void* data)
{
  std::lock_guard<std::mutex> lock{syscon_mutex};
  boost::filesystem::path temp_file_name = boost::filesystem::unique_path();
  boost::filesystem::path temppath = temp_file_path / temp_file_name;
  boost::filesystem::ofstream ofs(temppath, std::ios::out | std::ios::binary);
  if (ofs.fail()) {
    throw std::runtime_error("Failed to access the temporary file " + temppath.generic_string());
  }
  ofs.write(static_cast<const char *>(data), length);
  ofs.close();
  send_command(in, "master_write_from_file $::g_emif_ddr_service " + temppath.generic_string() + str( boost::format(" 0x%|08x|") % addr ) );
  if (0 != wait_for_prompt(out))
  {
    throw std::runtime_error("Unexpected EOF");
  }

  if (!preserve_temp_files) {
    try {
          boost::filesystem::remove(temppath);
        } catch (const boost::filesystem::filesystem_error& ex) {
          std::cerr << "Error removing file: " << ex.what() << std::endl;
    }
  }
}

static int setLoggerFile () {
  boost::filesystem::path loggerFilePath = boost::filesystem::current_path() / loggerFileName;
  if (loggerFile.is_open()) {
    throw std::runtime_error("A CSR logger file, " + loggerFilePath.generic_string() + ", has already been opened.");
  } else {
    loggerFile.open(loggerFilePath.generic_string(), std::ios::trunc);
    if (!loggerFile.is_open()) {
      throw std::runtime_error("Couldn't open CSR log file: " + loggerFilePath.generic_string());
    }
  }
  return 0;
}

MmdWrapper::MmdWrapper(const std::string& jtag_path, bool enableLog) {
  // Check for the envrionment variable
  auto env = boost::this_process::environment();
  tcl_file_path = env.find("DLA_SYSCON_SOURCE_FILE") != env.end() ?
      boost::filesystem::path(env["DLA_SYSCON_SOURCE_FILE"].to_string()) :
      boost::filesystem::path(xstr(DLA_SYSCON_SOURCE_ROOT)) / "system_console_script.tcl";
  if (!boost::filesystem::exists(tcl_file_path)) {
     throw std::runtime_error("Cannot locate " + tcl_file_path.generic_string() + ". Please specify the path of the Tcl setup script by defining the environment variable DLA_SYSCON_SOURCE_FILE\n");
  } else {
    std::cout <<"Using the Tcl setup script at "<<tcl_file_path.generic_string()<<std::endl;
  }

  temp_file_path = env.find("DLA_TEMP_DIR") != env.end() ?
    boost::filesystem::path(env["DLA_TEMP_DIR"].to_string()) :
    boost::filesystem::current_path();
  if (!boost::filesystem::exists(temp_file_path)) {
    throw std::runtime_error("The temporary file storage directory specified via the environment variable DLA_TEMP_DIR does not exist.\n");
  } else {
    std::cout <<"Saving temporary files to "<<temp_file_path.generic_string()<<std::endl;
  }

  sof_file_path = env.find("DLA_SOF_PATH") != env.end() ?
    boost::filesystem::path(env["DLA_SOF_PATH"].to_string()):
    boost::filesystem::current_path() / "top.sof";
  if (!boost::filesystem::exists(sof_file_path)) {
    throw std::runtime_error("Cannot find the FPGA bitstream (.sof). Please specify its location via the environment variable DLA_SOF_PATH,"\
     " or copy it as top.sof to the current working directory.\n");
  } else {
    std::cout <<"Using the FPGA bitstream at "<<sof_file_path.generic_string()<<" to configure the JTAG connection"<<std::endl;
  }

  timeout_ms = (unsigned int) DLA_SYSTEM_CONSOLE_TIMEOUT_MS;

  boost::filesystem::path system_console_path = bp::search_path("system-console");
  if (system_console_path.empty()) {
    throw std::runtime_error("Cannot find system-console in system PATH!\n");

  }
  enable_pmon = env.find("DLA_ENABLE_PMON") != env.end() ? 1 : 0;

  // Enable logging during debug mode, regardless of high level user setting
  if (env.find("COREDLA_RUNTIME_DEBUG") != env.end()) {
      this->logLevel_ = MmdLogLevel::INTERNAL;
  } else {
      this->logLevel_ = enableLog ? MmdLogLevel::ENABLE : MmdLogLevel::DISABLE;
  }
  csrLogLevel = this->logLevel_;
  if (csrLogLevel > MmdLogLevel::DISABLE) {
    try {
      setLoggerFile();
    } catch(std::runtime_error& ex) {
      std::cerr << "Failed to create the CSR logger file for the runtime." << std::endl;
    }
  }

  preserve_temp_files = loggerFile.is_open() ? true :
    env.find("DLA_PRESERVE_TEMP_FILES") != env.end() ? true : false;

  subprocess = bp::child(system_console_path, "-cli", bp::std_out > out, bp::std_in < in);
  if (wait_for_prompt(out))
  {
    throw std::runtime_error("Could not find initial prompt");
  }
  send_command(in, "set ::cl(sof) " + sof_file_path.generic_string());
  if (0 != wait_for_prompt(out)) {
    throw std::runtime_error("Unexpected EOF");
  }
  if (enable_pmon == 1) {
    send_command(in, "set ::cl(enable_pmon) 1");
    if (0 != wait_for_prompt(out)) {
      throw std::runtime_error("Unexpected EOF");
    }
  }
  if (!jtag_path.empty()) {
    send_command(in, "set ::cl(jtag_path) \"" + jtag_path + "\"");
    if (0 != wait_for_prompt(out)) {
      throw std::runtime_error("Unexpected EOF");
    }
  }
  send_command(in, "source " + tcl_file_path.generic_string());
  std::basic_stringstream<char> s1;
  if (0 != capture_till_prompt(out, s1))
  {
    throw std::runtime_error("Could not find prompt after source");
  }
  std::string captured(s1.str());
  std::cout << captured << std::endl;

  // Reset the IP
  write_to_csr(in, out, DLA_DMA_CSR_OFFSET_IP_RESET, 1);
  // Constants of the design
  maxInstances_ = 1;
  ddrSizePerInstance_ = 0x80000000;
  // Determine CoreDLA frequency
  const uint32_t start_bit = 1;
  const uint32_t stop_bit = 2;
  const uint32_t timer_address_offset = 0x800;
  // Send the start command to the hardware counter
  // Even though the API says "write_to_csr", address offset "timer_address_offset" actually maps to a hardware counter
  // that increments by 1 every DLA clock cycle
  this->disableCSRLogger();
  write_to_csr(in, out, timer_address_offset, start_bit);
  std::chrono::high_resolution_clock::time_point time_before = std::chrono::high_resolution_clock::now();
  // Unlikely to sleep for exactly 500 milliseconds, but it doesn't matter since we use a high resolution clock to
  // determine the amount of time between the start and stop commands for the hardware counter
  std::this_thread::sleep_for(std::chrono::milliseconds(500));

  // Stop the counter
  write_to_csr(in, out, timer_address_offset, stop_bit);
  std::chrono::high_resolution_clock::time_point time_after = std::chrono::high_resolution_clock::now();
  // Read back the frequency
  uint32_t dla_clock_count = read_from_csr(in, out, timer_address_offset);
  // Derive the frequency in MHz
  double elapsed_ms = std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(time_after - time_before).count();
  coreDlaClockFreq_ = 1.0e-3 * dla_clock_count / elapsed_ms; //convert the frequency in MHz

  // DDR frequency in MHz. AGX5 JTAG sets COREDLA_DDR_CLOCK_FREQ_MHZ to 300.
  // AGX3 and any build that does not set the macro keep 200 MHz.
#ifdef COREDLA_DDR_CLOCK_FREQ_MHZ
  ddrClockFreq_ = COREDLA_DDR_CLOCK_FREQ_MHZ;
#else
  ddrClockFreq_ = 200;
#endif

  // Initialize the handle_ object to a dummy value. It is not relevant to this MMD
  handle_ = 0;
}

MmdWrapper::~MmdWrapper() {
  send_command(in, "close_services");
  if (wait_for_prompt(out))
  {
    std::cout << "Could not find prompt after attempting to close system console services\n";
  }
  send_command(in, "exit");
  try {
    subprocess.terminate();
    std::cout << "Successfully closed JTAG services.\n";
  } catch (const bp::process_error& e) {
    std::cerr << "Failed to terminate the system-console process due to reason: " << e.what() << std::endl;
  }
  if (loggerFile.is_open()) {
    loggerFile.close();
  }
}

void MmdWrapper::enableCSRLogger() {
  // In user mode, the log can be enabled (=1) or disabled (=0)
  // In internal debug mode, logLevel_ is set to a value >= 2
  // in MmdWrapper(), such that all CSR logs are captured
  // regardless of calls to enable/disableCSRLogger
  this->logLevel_ = (this->logLevel_ < MmdLogLevel::INTERNAL) ? MmdLogLevel::ENABLE : this->logLevel_;
  csrLogLevel = this->logLevel_;
}

void MmdWrapper::disableCSRLogger() {
  // In user mode, the log can be enabled (=1) or disabled (=0)
  // In internal debug mode, logLevel_ is set to a value >= 2
  // in MmdWrapper(), such that all CSR logs are captured.
  // regardless of calls to enable/disableCSRLogger
  this->logLevel_ = (this->logLevel_ < MmdLogLevel::INTERNAL) ? MmdLogLevel::DISABLE : this->logLevel_;
  csrLogLevel = this->logLevel_;
}

void MmdWrapper::RegisterISR(interrupt_service_routine_signature func, void *data) const {
  throw std::runtime_error("System Console plugin requires polling");
}

void MmdWrapper::WriteToCsr(int instance, uint32_t addr, uint32_t data) const {
  write_to_csr(in, out, addr, data);
}

uint32_t MmdWrapper::ReadFromCsr(int instance, uint32_t addr) const {
  return read_from_csr(in, out, addr);
}

void MmdWrapper::WriteToDDR(int instance, uint64_t addr, uint64_t length, const void *data) const {
  write_to_ddr(in, out, addr, length, data);
}

void MmdWrapper::ReadFromDDR(int instance, uint64_t addr, uint64_t length, void *data) const {
  read_from_ddr(in, out, addr, length, data);
}

#ifndef STREAM_CONTROLLER_ACCESS
// Stream controller access is not supported by the platform abstraction
bool MmdWrapper::bIsStreamControllerValid(int instance) const { return false; }

// 32-bit handshake with each Stream Controller CSR
void MmdWrapper::WriteToStreamController(int instance, uint32_t addr, uint64_t length, const void *data) const {
  assert(false);
}

void MmdWrapper::ReadFromStreamController(int instance, uint32_t addr, uint64_t length, void *data) const {
  assert(false);
}
#else
// If the mmd layer supports accesses to the Stream Controller
bool MmdWrapper::bIsStreamControllerValid(int instance) const {
  return false;
}

// 32-bit handshake with each Stream Controller CSR
void MmdWrapper::WriteToStreamController(int instance, uint32_t addr, uint64_t length, const void *data) const {
}

void MmdWrapper::ReadFromStreamController(int instance, uint32_t addr, uint64_t length, void *data) const {
}
#endif

bool MmdWrapper::InitIStreamFifo(const std::string& fifo_file) const {
  return false;
}
int MmdWrapper::SetOStreamOutputShape(uint64_t channels, uint64_t height, uint64_t width, uint64_t c_vec) const {
  return -1;
}
void MmdWrapper::GetBufferedStreamOutData(int instance, void* data) const {}
void MmdWrapper::StreamInData(int instance, uint64_t length) const {}
void MmdWrapper::StreamOutData(int instance) const {}
void MmdWrapper::OnlineReconfig(const std::string& mifs_path) const {}
void MmdWrapper::AcquireOstreamLock() const {}
void MmdWrapper::ReleaseOstreamLock() const {}

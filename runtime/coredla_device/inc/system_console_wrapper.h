// Copyright 2020-2024 Altera Corporation.
//
// This software and the related documents are Altera copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Altera's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

// This MMD object can only support one inference request.
// TODO: factor this system-console MMD into its own "aocl" layer.
//       The hostless-ED runtime should use the generic MMD interface
//       to access the "aocl" layer

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
#include <iostream>
#include <string>
#include <regex>
#include <sstream>
#include <ostream>
#include <chrono>
#include <thread>
#include <mutex>
#include <fstream> // std::ofstream
#include <iomanip>
namespace bp = boost::process::v1;
namespace fs = boost::filesystem;

// default timeout is 80 seconds
#define DLA_SYSTEM_CONSOLE_TIMEOUT_MS 80000

// wraps a system console instance, used for communicating over JTAG
class SystemConsoleWrapper {
  bp::opstream in;
  bp::ipstream out;
  bp::child subprocess;
  fs::path rpath;
  fs::path wpath;
  int64_t timeout_ms = DLA_SYSTEM_CONSOLE_TIMEOUT_MS;

public:
  int64_t set_timeout_ms(int64_t t) {
    int64_t old_timeout = timeout_ms;
    timeout_ms = t;
    return old_timeout;
  }

  static std::string remove_non_alphanumeric(const std::string& input) {
    std::string result = input;
    result.erase(std::remove_if(result.begin(), result.end(), [](unsigned char c) {
    return !std::isalnum(c);
    }), result.end());
    return result;
  }

  fs::path temp_dir() {
    return rpath.parent_path();
  }

  std::string get_output() {
    std::string buffer;
    auto captureEndingTime = std::chrono::system_clock::now() + std::chrono::milliseconds(timeout_ms);

    // read output one line at a time. start by checking the first char of the line.
    // If the frist char is % then it is a new prompt and we are done
    for (bp::ipstream::int_type x = out.get(); (x != static_cast<bp::ipstream::int_type>('%') || out.peek() != static_cast<bp::ipstream::int_type>(' ')); x = out.get()) {
      if (out.fail()) {
        throw std::runtime_error("Unexpected EOF when reading from system-console");
      }
      if (std::chrono::system_clock::now() > captureEndingTime) {
        throw std::runtime_error("Timeout when reading from system-console");
      }
      buffer += x;
    }
    out.get();
    return buffer;
  }

  template <typename... Args>
  std::string send_command(Args&&... args) {
    std::stringstream ss;
    ((ss << args << " "), ...);
    std::string command = ss.str();
    if (command.back() == ' ') {
      command.erase(command.size() - 1); // remove trailing space
    }
    in << command << "\n";
    in.flush();
    std::string output = get_output();
    // Output sometimes echos the command back, so trim that off
    int i = 0;
    while (output[i] == command[i] && i < command.size()) {
      i++;
    }
    // Remove trailing whitespace
    int j = output.size() - 1;
    while (j >= i && std::isspace(output[j])) {
      j--;
    }
    return output.substr(i, j - i + 1);
  }

  void write_32(std::string& service, unsigned int addr, unsigned int data) {
    send_command("master_write_32", service, str( boost::format("0x%|08x| 0x%|08x|") % addr % data));
  }

  unsigned int read_32(std::string& service, unsigned int addr) {
      auto res = send_command("master_read_32", service, str( boost::format("0x%|08x| 0x%|08x|") % addr % 1));
      return std::stoul(remove_non_alphanumeric(res), nullptr, 16);
  }

  void read(std::string& service, unsigned int addr, unsigned int length, void* data) {
    if (data == nullptr) {
      throw std::runtime_error("read: data must be a valid pointer");
    }
    send_command("master_read_to_file", service, rpath.native(), str( boost::format("0x%|08x| 0x%|08x|") % addr % length));
    std::ifstream ifs(rpath, std::ios::in | std::ios::binary);
    if (!ifs) {
      throw std::runtime_error("read: failed to open temporary file for reading stream out data");
    }
    ifs.read(static_cast<char *>(data), length);
    ifs.close();
  }

  void write(std::string& service, unsigned int addr, unsigned int length, const void* data) {
    if (data == nullptr) {
      throw std::runtime_error("write: data must be a valid pointer");
    }
    std::ofstream ofs(wpath, std::ios::out | std::ios::binary);
    if (!ofs) {
      throw std::runtime_error("write: failed to open temporary file for writing stream in data");
    }
    ofs.write(static_cast<const char *>(data), length);
    ofs.close();
    send_command("master_write_from_file", service, wpath.native(), str( boost::format("0x%|08x|") % addr));
  }

  template <typename... Args>
  std::string claim_service(std::string master, std::string reg, Args&&... args) {
    send_command("set paths [get_service_paths", master, "]");
    send_command("set jtag_path", "\"" + reg + "\"");
    send_command("set path [lindex $paths [lsearch -glob $paths $jtag_path]]");
    auto path = send_command("puts \"$path\"");
    if (path == "") {
      throw std::runtime_error("claim_service: no path matching " + reg + " found for " + master);
    } else {
      std::cout << "Using " << path << " for " << master << " path" << std::endl;
    }
    std::string service = send_command("claim_service", master, "$path", std::forward<Args>(args)...);
    if (service.empty()) {
      throw std::runtime_error("claim_service: failed to claim service");
    }
    return service;
  }

  SystemConsoleWrapper() {
    fs::path temp_path;
    try {
      temp_path = fs::temp_directory_path();
    } catch (const fs::filesystem_error& e) {
      temp_path = fs::current_path();
    }
    wpath = temp_path;
    wpath.append("system_console_temp_write.bin");
    rpath = temp_path;
    rpath.append("system_console_temp_read.bin");
    boost::filesystem::path system_console_path = bp::search_path("system-console");
    if (system_console_path.empty()) {
      throw std::runtime_error("Cannot find system-console in system PATH!");
    }
    boost::filesystem::path jtagconfig_path = bp::search_path("jtagconfig");
    if (jtagconfig_path.empty()) {
      throw std::runtime_error("Cannot find jtagconfig in system PATH!");
    }
    // check that there is an fpga device connected
    bp::ipstream jtag_out;
    bp::child jtag_subprocess(jtagconfig_path, bp::std_out > jtag_out);
    std::string jtag_line;
    while (std::getline(jtag_out, jtag_line)) {
      if (jtag_line == "No JTAG hardware available") {
        throw std::runtime_error("No JTAG hardware available! Please connect an FPGA device.");
      }
    }
    jtag_subprocess.wait();
    // set the clock speed for JTAG to 16MHz
    jtag_subprocess = bp::child(jtagconfig_path, "--setparam", "1", "JtagClock", "16M");
    jtag_subprocess.wait();
    // sometimes system-console does not see master paths, so try a few times
    for (int i = 0; i < 10; i++) {
      subprocess = bp::child(system_console_path, "-cli", bp::std_out > out, bp::std_in < in);
      get_output();
      std::string num_master_services = send_command("llength [get_service_paths master]");
      if (std::stoi(num_master_services) > 0) {
        break;
      } else {
        std::cout << "No valid master services found. Restarting system-console..." << std::endl;
        in << "exit" << "\n";
        in.flush();
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
        subprocess.terminate();
        if (i == 2) {
          throw std::runtime_error("Failed to start system-console with valid master services after 3 attempts.");
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(1000));
      }
    }
  }

  ~SystemConsoleWrapper() {
    // exit system-console
    in << "exit" << "\n";
    in.flush();
    try {
      subprocess.terminate();
      std::cout << "Successfully closed JTAG services.\n";
    } catch (const bp::process_error& e) {
      std::cerr << "Failed to terminate the system-console process: " << e.what() << std::endl;
    }
    // clean up temp files
    if (fs::exists(rpath)) {
      fs::remove(rpath);
    }
    if (fs::exists(wpath)) {
      fs::remove(wpath);
    }
  }
};

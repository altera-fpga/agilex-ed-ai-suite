# Spark Demo Unified Makefile
# Builds both C executable and Python module

# Build targets
C_TARGET = spark_demo
PYTHON_MODULE = fpgademo

# Build directory
OBJDIR = obj

# Compiler settings
CC ?= gcc
CXX ?= g++
COPT ?= -g -O2

# Base flags
CFLAGS = $(COPT)
CPPFLAGS = -std=c++11

# Debug/Assert flags
ifndef ndebug
CPPFLAGS += -DENABLE_DEBUG=1
endif
ifndef nassert
CPPFLAGS += -DENABLE_ASSERT=1
endif

# Security flags (all on single lines to avoid padding)
CFLAGS += -fstack-protector -D_FORTIFY_SOURCE=2 -Wformat -Wformat-security -fPIE -fPIC
LDFLAGS = -z noexecstack -z relro -z now -pie

# Libraries
LDFLAGS += -luuid
FPGA_LIBS = -lopae-c
COMMON_LIBS = -lrt -pthread

# Include paths
CFLAGS += -I./$(OBJDIR)
CPPFLAGS += -I./$(OBJDIR)

# Source files
C_SRCS = main.c demo.c fpga.c path_utils.c
SHARED_SRCS = demo.c fpga.c
WRAPPER_SRC = fpga_wrapper.cpp

# Object files
C_OBJS = $(addprefix $(OBJDIR)/,$(patsubst %.c,%.o,$(C_SRCS)))
SHARED_OBJS = $(addprefix $(OBJDIR)/,$(patsubst %.c,%.o,$(SHARED_SRCS)))

# Python configuration - support for override through PYTHON_BIN
# Default version is set to python 3.12 (this is what tiny-stories demo is using)
PYTHON_BIN ?= python3.12
PYTHON_CONFIG = $(PYTHON_BIN)-config
PYTHON_INCLUDE_RAW = $(shell $(PYTHON_CONFIG) --includes)
PYTHON_LDFLAGS = $(shell $(PYTHON_CONFIG) --ldflags --embed)
PYTHON_LIBS = $(shell $(PYTHON_CONFIG) --libs --embed)
PYTHON_EXT = $(shell $(PYTHON_CONFIG) --extension-suffix)

# Get pybind11 includes separately
PYBIND11_INCLUDE_RAW = $(shell $(PYTHON_BIN) -m pybind11 --includes)

# Extract unique include directories only
# This removes duplicates more effectively by extracting just the paths
PYTHON_DIRS = $(sort $(patsubst -I%,%,$(filter -I%,$(PYTHON_INCLUDE_RAW))))
PYBIND11_DIRS = $(sort $(patsubst -I%,%,$(filter -I%,$(PYBIND11_INCLUDE_RAW))))
ALL_INCLUDE_DIRS = $(sort $(PYTHON_DIRS) $(PYBIND11_DIRS))
ALL_PYTHON_INCLUDES = $(patsubst %,-I%,$(ALL_INCLUDE_DIRS))

# Python-specific flags
PYTHON_CPPFLAGS = $(CPPFLAGS) $(ALL_PYTHON_INCLUDES) -fPIC
PYTHON_CXXFLAGS = $(PYTHON_CPPFLAGS)
PYTHON_LD = $(filter-out -pie,$(LDFLAGS))

# Python module target name
PYTHON_TARGET = $(PYTHON_MODULE)$(PYTHON_EXT)

# Test script
PYBIND_TEST_SCRIPT = pybind_fpga_full_test.py

# Phony targets
.PHONY: all exe pybind test clean help test-exe test-pybind

# Default builds both
all: exe pybind

# Build C executable
exe: $(C_TARGET)

# Build Python module
pybind: $(PYTHON_TARGET)

# AFU JSON info generation
AFU_JSON_INFO = $(OBJDIR)/afu_json_info.h
$(AFU_JSON_INFO): ../hw/spark_demo.json | $(OBJDIR)
	afu_json_mgr json-info --afu-json=$^ --c-hdr=$@

# Build C executable
$(C_TARGET): $(C_OBJS)
	$(CC) -o $@ $^ $(LDFLAGS) $(FPGA_LIBS) $(COMMON_LIBS)

# Build Python module
$(PYTHON_TARGET): $(SHARED_OBJS) $(OBJDIR)/fpga_wrapper.o
	$(CXX) -shared -fPIC -o $@ $^ $(PYTHON_LD) $(FPGA_LIBS) $(COMMON_LIBS) $(PYTHON_LDFLAGS) $(PYTHON_LIBS)

# C object files
$(OBJDIR)/%.o: %.c $(AFU_JSON_INFO) | $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $@

# C++ wrapper object
$(OBJDIR)/fpga_wrapper.o: $(WRAPPER_SRC) config.h | $(OBJDIR)
	$(CXX) $(PYTHON_CXXFLAGS) -c $< -o $@

# Test targets
test: test-exe test-pybind

test-exe: $(C_TARGET)
	@echo "Testing C executable..."
	./$(C_TARGET)

test-pybind: $(PYTHON_TARGET)
	@echo "Testing Python module..."
	@if [ -f $(PYBIND_TEST_SCRIPT) ]; then \
		$(PYTHON_BIN) $(PYBIND_TEST_SCRIPT); \
	else \
		echo "Test script $(PYBIND_TEST_SCRIPT) not found"; \
		echo "Falling back to import test..."; \
		$(PYTHON_BIN) -c "import $(PYTHON_MODULE); print('$(PYTHON_MODULE) imported successfully')"; \
	fi

# Clean all built files
clean:
	rm -rf $(OBJDIR) $(C_TARGET) *.so

# Create build directory
$(OBJDIR):
	@mkdir -p $@

# Show build configuration
debug:
	@echo "=== Python Environment ==="
	@echo "Python binary: $(PYTHON_BIN)"
	@echo "Python config: $(PYTHON_CONFIG)"
	@echo "=== Build Targets ==="
	@echo "C executable: $(C_TARGET)"
	@echo "Python module: $(PYTHON_TARGET)"
	@echo "Test script: $(PYBIND_TEST_SCRIPT)"
	@echo "=== Compiler Flags ==="
	@echo "CFLAGS: $(CFLAGS)"
	@echo "LDFLAGS: $(LDFLAGS)"
	@echo "Python CXXFLAGS: $(PYTHON_CXXFLAGS)"
	@echo "=== Python Include Details ==="
	@echo "python3-config output: $(PYTHON_INCLUDE_RAW)"
	@echo "pybind11 output: $(PYBIND11_INCLUDE_RAW)"
	@echo "Combined (sorted): $(ALL_PYTHON_INCLUDES)"
	@echo "=== Sources ==="
	@echo "C sources: $(C_SRCS)"
	@echo "Shared sources: $(SHARED_SRCS)"

# Help
help:
	@echo "Spark Demo Build System"
	@echo "======================"
	@echo "Targets:"
	@echo "  all         - Build both C executable and Python module (default)"
	@echo "  exe         - Build the C executable"
	@echo "  pybind      - Build the Python module"
	@echo "  test        - Run all tests"
	@echo "  test-exe    - Test C executable"
	@echo "  test-pybind - Test Python module with $(PYBIND_TEST_SCRIPT)"
	@echo "  clean       - Remove all built files"
	@echo "  debug       - Show build configuration"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  PYTHON_BIN  - Override Python executable (default: python3)"
	@echo "               Example: make pybind PYTHON_BIN=python3.12"
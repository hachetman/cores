######################################################################
#
# DESCRIPTION: Verilator CMake Example: Small CMakeLists.txt with SystemC
#
# This is an example cmake script to build a verilog to SystemC project
# using CMake and Verilator.
#
# Copyright 2003-2019 by Wilson Snyder. This program is free software; you can
# redistribute it and/or modify it under the terms of either the GNU
# Lesser General Public License Version 3 or the Perl Artistic License
# Version 2.0.
#
######################################################################

# This example builds the tracing_sc example using CMake
# To use it, run the following:

# cd /path/to/verilator/examples/cmake_sc
# rm -rf build && mkdir build && cd build
# cmake ..
# cmake --build .

cmake_minimum_required(VERSION 3.8)
project(cores)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()
include(cmake/yosys_formal.cmake)
# Create a new executable target that will contain all your sources

add_subdirectory(sim)
#add_subdirectory(formal)

yosys_formal_project(
    TARGET uart
    HDL_INCLUDE "${CMAKE_CURRENT_SOURCE_DIR}/hdl"
  )
yosys_formal_project(
    TARGET uart2
    HDL_INCLUDE "${CMAKE_CURRENT_SOURCE_DIR}/hdl"
  )

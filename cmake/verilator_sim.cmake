cmake_minimum_required(VERSION 3.10)

set(SIM_SCRIPT_DIR ${CMAKE_CURRENT_LIST_DIR})

macro(verilator_sim_project)
  set(options "")
  set(oneValueArgs
    TARGET
    HDL_INCLUDE
    )
  cmake_parse_arguments(SIM "${options}" "${oneValueArgs}"
    "${multiValueArgs}" ${ARGN} )
  message("Creating Simulation for Target '${SIM_TARGET}'")
  message("Creating Simulation in '${SIM_SCRIPT_DIR}'")
  add_executable(${SIM_TARGET}.sim ../sim/${SIM_TARGET}_sim.cpp)
  add_custom_command(TARGET ${SIM_TARGET}.sim POST_BUILD
    COMMAND ./${SIM_TARGET}.sim +trace)
  verilate(uart.sim COVERAGE TRACE
    INCLUDE_DIRS "${SIM_HDL_INCLUDE}"
    VERILATOR_ARGS -f ${SIM_SCRIPT_DIR}/../input.vc -Os -x-assign 0
    SOURCES ${SIM_SCRIPT_DIR}/../hdl/${SIM_TARGET}.sv)
endmacro()



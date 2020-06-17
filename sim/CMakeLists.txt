cmake_minimum_required(VERSION 3.10)


add_executable(uart.sim uart_sim.cpp)
add_custom_command(TARGET uart.sim POST_BUILD
			  COMMAND echo "running uart simulation"
			  COMMAND ./uart.sim +trace)
# Add the Verilated circuit to the target
verilate(uart.sim COVERAGE TRACE
  INCLUDE_DIRS "../hdl/"
  VERILATOR_ARGS -f ../input.vc -Os -x-assign 0
  SOURCES ../hdl/uart.sv)



cmake_minimum_required(VERSION 3.10)


add_executable(uart_sim uart_sim.cpp)
add_custom_command(TARGET uart_sim POST_BUILD
			  COMMAND echo "running uart simulation"
			  COMMAND ./uart_sim +trace)
# Add the Verilated circuit to the target
verilate(uart_sim COVERAGE TRACE
  INCLUDE_DIRS "../hdl/"
  VERILATOR_ARGS -f ../input.vc -Os -x-assign 0
  SOURCES ../hdl/uart.sv)



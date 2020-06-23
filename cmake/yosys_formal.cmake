set(FORMAL_SCRIPT_DIR ${CMAKE_CURRENT_LIST_DIR})

macro(yosys_formal_project)
  set(options "")
  set(oneValueArgs
    TARGET
    HDL_INCLUDE
    )

  cmake_parse_arguments(FORMAL "${options}" "${oneValueArgs}"
    "${multiValueArgs}" ${ARGN} )
  message("Creating an FPGA Build for Target '${FORMAL_TARGET}'")
  FILE(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${FORMAL_TARGET}.ys  "read_verilog -sv -formal ${FORMAL_HDL_INCLUDE}/*\n")
  FILE(APPEND ${CMAKE_CURRENT_BINARY_DIR}/${FORMAL_TARGET}.ys  "prep -top ${FORMAL_TARGET}\n")
  FILE(APPEND ${CMAKE_CURRENT_BINARY_DIR}/${FORMAL_TARGET}.ys  "write_smt2 -wires ${FORMAL_TARGET}.smt2")

  add_custom_target(${FORMAL_TARGET}.smt2
    COMMAND yosys -s ${FORMAL_TARGET}.ys)
  add_custom_target(${FORMAL_TARGET}.proove
    COMMAND yosys-smtbmc -g --dump-vcd ${FORMAL_TARGET}_proove.vcd ${FORMAL_TARGET}.smt2
    DEPENDS ${FORMAL_TARGET}.smt2)
  add_custom_target(${FORMAL_TARGET}.cover
    COMMAND echo ${CMAKE_CURRENT_BINARY_DIR}
    COMMAND yosys-smtbmc -c -t 150 --dump-vcd ${FORMAL_TARGET}_cover.vcd ${FORMAL_TARGET}.smt2
    DEPENDS ${FORMAL_TARGET}.smt2)
endmacro()

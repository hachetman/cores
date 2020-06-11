
// Include model header, generated from Verilating "top.v"
#include "Vuart.h"

// Testbench helpers
#include "testbench.hpp"
int main(int argc, char** argv, char** env) {
  // This is a more complicated example, please also see the simpler examples/make_hello_c.

  // Prevent unused variable warnings
  if (0 && argc && argv && env) {}

  // Set debug level, 0 is off, 9 is highest presently used
  // May be overridden by commandArgs
  Verilated::debug(0);

  // Randomization reset policy
  // May be overridden by commandArgs
  Verilated::randReset(2);

  // Pass arguments so Verilated code can see them, e.g. $value$plusargs
  // This needs to be called before you create any model
  Verilated::commandArgs(argc, argv);

  // Create logs/ directory in case we have traces to put under it
  Vuart* top = new Vuart;
  Testbench<Vuart>* testbench = new Testbench<Vuart>(top);
  testbench->register_clk(&top->clk_i);
  testbench->tick();
  while (main_time < 10) {
    testbench->tick();
  }
  printf("Simulation  done\n");
  // Final model cleanup
  top->final();
  delete testbench;
  //  Coverage analysis (since test passed)
#if VM_COVERAGE
  Verilated::mkdir("logs");
  VerilatedCov::write("logs/uart_coverage.dat");
#endif

  // Destroy model
  delete top;
  top = NULL;

  // Fin
  exit(0);
}

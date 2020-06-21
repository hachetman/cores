
// Include model header, generated from Verilating "top.v"
#include "Vuart.h"

// Testbench helpers
#include "testbench.hpp"
#include "axis_master_agent.hpp"
#include "uart_agent.hpp"
int main(int argc, char** argv, char** env) {
  // This is a more complicated example, please also see the simpler examples/make_hello_c.
  CData uart_send_data;
  int error_count = 0;
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
  axis_master_agent<1, CData> * master_agent = new axis_master_agent<1, CData>();
  master_agent->bind_ports(&top->s_axis_tvalid_i , &top->s_axis_tready_o,
                           &top->s_axis_tdata_i);
  testbench->register_clk(&top->clk_i);
  testbench->register_tick(std::bind(&axis_master_agent<1, CData>::tick, master_agent));
  uart_agent *uart_tester = new uart_agent();
  uart_tester->bind_ports(&top->uart_tx_o, &top->uart_rx_i);
  testbench->register_tick(std::bind(&uart_agent::tick, uart_tester));

  testbench->tick();
  testbench->tick();
  uart_send_data = 0xa5;
  master_agent->queue_data(&uart_send_data);
  uart_tester->queue_data(&uart_send_data);
  uart_send_data = 0xAA;
  master_agent->queue_data(&uart_send_data);
  while (main_time < 500) {
    testbench->tick();
  }
  printf("Simulation  done, checking values received from DUT\n");
  if (uart_tester->rx_data_queue.size() != 0){
    if (uart_tester->rx_data_queue.front()!= 0xa5) {
      std::cout << "ERROR: got wrong data in the FIFO\n";
      error_count++;
    }
    uart_tester->rx_data_queue.pop();
  } else {
    std::cout << "ERROR: not data found\n";
    error_count++;
  }
  if (uart_tester->rx_data_queue.size() != 0){
    if (uart_tester->rx_data_queue.front()!= 0xaa) {
      std::cout << "ERROR: got wrong data in the FIFO\n";
      error_count++;
    }
    uart_tester->rx_data_queue.pop();
  }
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
  if (error_count == 0) {
    exit(0);
  }  else {
    exit(1);
  }
}

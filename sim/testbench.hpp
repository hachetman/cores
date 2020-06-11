#ifndef TESTBENCH_HPP
#define TESTBENCH_HPP

#include <functional>
#include <list>
#include <iostream>
#include "verilated.h"
#include "verilated_vcd_c.h"


vluint64_t main_time = 0;
double sc_time_stamp() {
  return main_time;
}

template <class MODULE>
class Testbench {
 protected:
  CData *dut_clk;
  std::list<std::function<void()>> agent_list;
  public:
  MODULE *dut;  
  VerilatedVcdC *trace;
  Testbench(MODULE *top);
  ~Testbench();
  void tick();
  void register_clk(CData *Clk);
  void register_tick(std::function<void() > agent);
};

template <class MODULE>
Testbench<MODULE>::Testbench(MODULE *top) {
  Verilated::traceEverOn(true);
  Verilated::mkdir("logs");
  std::string vcdfile = "logs/";
  vcdfile.append(typeid(MODULE).name());
  vcdfile.append(".vcd");
  vcdfile.erase(5,1);
  dut = top;
  trace = new VerilatedVcdC;
  dut->trace (trace, 99);
  std::cout << "logging to: " << vcdfile << std::endl;
  trace->open (vcdfile.c_str());
}

template <class MODULE>
Testbench<MODULE>::~Testbench(void) {
  printf("Closing Trace File\n");
  trace->close();
}

template <class MODULE>
void Testbench<MODULE>::register_clk(CData *clk) {
  printf("Registering Clock\n");
  dut_clk = clk;
  *dut_clk = 0;
}
template <class MODULE>
void Testbench<MODULE>::register_tick(std::function<void() > agent) {
  agent_list.push_back(agent);
}

template <class MODULE>
void Testbench<MODULE>::tick(void) {
  // this shall me the main sim routine
  main_time ++;
  if (*dut_clk == 0) {
    for( std::list<std::function<void()>>::iterator f = agent_list.begin(); f != agent_list.end(); ++f ){
      (*f)();
    }
  }
 *dut_clk = !*dut_clk;
 trace->dump(main_time);
 dut->eval();
  
}

#endif /*TESTBENCH_HPP */

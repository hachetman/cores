#ifndef AXIS_MASTER_AGENT_HPP
#define AXIS_MASTER_AGENT_HPP
#include "verilated.h"
#include <queue>
#include <iostream>
template <size_t size = 16>
class axis_master_agent {
public:
  CData *valid;
  CData *ready;
  WData *data;
  std::queue<WData> data_queue;
  void tick();
  int bind_ports(CData *valid, CData *ready, WData *data);
  int queue_data(WData *data);
};

template <size_t size>
void axis_master_agent<size>::tick(void) {
  std::cout << "master_agent::tick" << std::endl;
  if (data_queue.size() != 0) {
    std::cout << "Something in the FIFO" << std::endl;
    *this->valid = 1;
    if (*this->ready == 1) {
      for (int i = 0; i < size; i++) {
        data[i] = data_queue.front();
        data_queue.pop();
      }
    }
  } else {
    *this->valid = 0;
  }
};

template <size_t size>
int axis_master_agent<size>::bind_ports(CData *valid, CData *ready, WData *data) {
  std::cout << "Binding the ports" << std::endl;
  this->valid = valid;
  this->ready = ready;
  this->data = data;
  *this->valid = 0;
  for (int i = 0; i < size; i++) {
    *(this->data+i) = 0;
  }
  return 0;
};
template <size_t size>
int axis_master_agent<size>::queue_data(WData *data) {
  std::cout << "Queuing data to be send" << std::endl;
  for (int i = 0; i < size ; i++) {
    data_queue.push(data[i]);
  }
  return 0;
}
#endif

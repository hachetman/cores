#ifndef AXIS_MASTER_AGENT_HPP
#define AXIS_MASTER_AGENT_HPP
#include "verilated.h"
#include <queue>
#include <iostream>
template <size_t size = 16, class T= CData>
class axis_master_agent {
public:
  CData *valid;
  CData *ready;
  T *data;
  std::queue<T> data_queue;
  void tick();
  int bind_ports(CData *valid, CData *ready, T *data);
  int queue_data(T *data);
};

template <size_t size, class T>
void axis_master_agent<size, T>::tick(void) {
  if (data_queue.size() != 0) {
    *this->valid = 1;
    for (int i = 0; i < size; i++) {
      data[i] = data_queue.front();
    }
    if (*this->ready == 1) {
      data_queue.pop();
      std::cout << "popping one element" << std::endl;
    }
  } else {
    *this->valid = 0;
  }
};

template <size_t size, class T>
int axis_master_agent<size, T>::bind_ports(CData *valid, CData *ready, T *data) {
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
template <size_t size, class T>
int axis_master_agent<size, T>::queue_data(T *data) {
  std::cout << "Queuing data to be send" << std::endl;
  for (int i = 0; i < size ; i++) {
    data_queue.push(data[i]);
  }
  return 0;
}
#endif

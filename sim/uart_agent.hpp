#ifndef UART_AGENT_HPP
#define UART_AGENT_HPP
#include "verilated.h"
#include <queue>
#include <iostream>

class uart_agent {
public:
  CData *rx;
  CData *tx;
  std::queue<CData> rx_data_queue;
  std::queue<CData> tx_data_queue;
  void tick();
  int bind_ports(CData *rx, CData *tx);
  int queue_data(CData *data);
  int read_data(CData *data);
private:
  int tx_data_cnt= 0;
  int rx_data_cnt= 0;
  int uart_clk_ena;
  int clk_cnt = 0;
  int clocks_per_baud = 10;
  void tx_tick();
  void rx_tick();
  void uart_clk_ena_tick();
  CData rx_data;
};

void uart_agent::tick(void) {
  uart_clk_ena_tick();
  tx_tick();
  rx_tick();
}



int uart_agent::bind_ports(CData *rx, CData *tx) {
  this->rx = rx;
  this->tx = tx;
  *this->tx = 1;
  return 0;
}

int uart_agent::queue_data(CData *data) {
  std::cout << "Queuing data to be send" << std::endl;
  tx_data_queue.push(*data);
  return 0;
}

void uart_agent::uart_clk_ena_tick() {
  if ( clk_cnt == clocks_per_baud) {
      clk_cnt = 0;
      uart_clk_ena = 1;
    } else{
      clk_cnt += 1;
      uart_clk_ena = 0;
    }
}

void uart_agent::tx_tick(void) {
  if (tx_data_queue.size() != 0) {
    switch(tx_data_cnt) {
    case 0:
      // Default
      *this->tx = 1;
      break;
    case 1:
      // start condition
      *this->tx = 0;
      break;
    case 10:
      // stop condition
      *this->tx = 1;
      break;
    default:
      if (tx_data_queue.front() & (1 << (tx_data_cnt-2))) {
          *this->tx = 1;
        } else {
          *this->tx = 0;
        }
      break;
    }
    if ( uart_clk_ena) {
      tx_data_cnt++;
    }
    if (tx_data_cnt == 11) {
      tx_data_cnt = 0;
      tx_data_queue.pop();
    }
  }
}
void uart_agent::rx_tick(void) {
  if (uart_clk_ena) {
    switch(rx_data_cnt) {
    case 0:
      // Default
      if (*this->rx == 0) {
        rx_data_cnt++;
        rx_data = 0;
      }
      break;
    case 1 ... 8:
      if (*this->rx != 0) {
        rx_data = rx_data | (1 << (rx_data_cnt-1));
      }
      rx_data_cnt++;
      break;
    case 9:
      rx_data_cnt = 0;
      if (*this->rx != 0) {
        rx_data_queue.push(rx_data);
      }
      break;
    default:
      break;
    }
  }
}

#endif

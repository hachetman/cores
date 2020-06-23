module uart #
(parameter BAUD        = 115200,
 parameter CLK_FREQ    = 600000)
(
 input  wire         clk_i,
// AXI STREAM SLAVE INTERFACE
 input  wire [7:0]   s_axis_tdata_i,
 input  wire         s_axis_tvalid_i,
 output reg          s_axis_tready_o,

// AXI STREAM MASTER INTERFACE
 output wire [7:0]   m_axis_tdata_o,
 output wire         m_axis_tvalid_o,
 input  wire         m_axis_tready_i,

// UART interface
 input  wire         uart_rx_i,
 output reg          uart_tx_o
);


localparam CLK_PER_BAUD = CLK_FREQ / BAUD;

enum {IDLE, START, TRANSMIT, RECEIVE, AXI_SEND, STOP} uart_tx_state, uart_rx_state;
initial uart_tx_state = IDLE;
initial uart_rx_state = IDLE;

reg [7:0]  tx_data;
reg [7:0]  rx_data;
reg [2:0]  tx_bit_cnt;
reg [2:0]  rx_bit_cnt;
reg [15:0] baud_cnt = 0;
reg baud_clk_ena;

assign m_axis_tdata_o = rx_data;

always @(posedge clk_i)
  begin: BAUD_CLK_ENA
  baud_cnt <= baud_cnt + 1;
      baud_clk_ena <= 0;
      if (baud_cnt == CLK_PER_BAUD[15:0]) begin
          baud_cnt <= 0;
          baud_clk_ena <= 1;
      end
  end


always @(posedge clk_i)
  begin : TX_STATE_MACHINE
      case(uart_tx_state)
          IDLE: begin
              if (s_axis_tvalid_i == 1'b1) begin
                  uart_tx_state <= START;
                  tx_data <= s_axis_tdata_i;
              end
          end
          START: begin
              tx_bit_cnt <= 'h0;
              if (baud_clk_ena) begin
                  uart_tx_state <= TRANSMIT;
              end
          end
          TRANSMIT: begin
              if (baud_clk_ena) begin
                  tx_bit_cnt <= tx_bit_cnt + 1;
                  tx_data <= {tx_data[0], tx_data[7:1]};
                  if (tx_bit_cnt == 'h7) begin
                      uart_tx_state <= STOP;
                  end
              end
          end
          STOP: begin
              if (baud_clk_ena) begin
                  uart_tx_state <= IDLE;
              end
          end
      endcase
  end

always @ (*)
  begin: TX_OUTPUT
    s_axis_tready_o = 1'b0;
    uart_tx_o       = 1'b1;
    case(uart_tx_state)
        IDLE: begin
            s_axis_tready_o = 1'b1;
        end
        START: begin
            uart_tx_o = 1'b0;
        end
	TRANSMIT: begin
            uart_tx_o = tx_data[0];
	end
        STOP: begin
            uart_tx_o = 1'b1;
        end
	default: begin
	end
    endcase
end


always @(posedge clk_i)
  begin : RX_STATE_MACHINE
      case(uart_rx_state)
          IDLE: begin
              if (baud_clk_ena) begin
                  if (uart_rx_i == 0) begin
                      uart_rx_state <= RECEIVE;
                      rx_bit_cnt <= 0;
                      rx_data <= 0;
                  end
              end
          end
          RECEIVE: begin
              if (baud_clk_ena) begin
                  rx_bit_cnt <= rx_bit_cnt + 1;
                  rx_data <= {rx_data[6:0], uart_rx_i};
                  if (rx_bit_cnt == 'h7) begin
                      uart_rx_state <= STOP;
                  end
              end
          end
          STOP: begin
              if (baud_clk_ena) begin
                  if (uart_rx_i == 1'b1) begin
                      uart_rx_state <= AXI_SEND;
                  end else begin
                      uart_rx_state <= IDLE;
                  end
              end
          end
          AXI_SEND: begin
              if (m_axis_tready_i == 1) begin
                uart_rx_state <= IDLE;
              end
          end
      endcase
  end

always @ (*)
  begin: RX_OUTPUT
    m_axis_tvalid_o = 1'b0;
    case(uart_rx_state)
        AXI_SEND: begin
            m_axis_tvalid_o = 1'b1;
        end
	default: begin
	end
    endcase
end

`ifdef FORMAL

// Keep track of a flag telling us whether or not $past()
// will return valid results
reg f_past_valid;
initial	f_past_valid = 1'b0;
always @(posedge clk_i)
	f_past_valid = 1'b1;

// ASSUMPTIONS
// Produce less search space
always @(posedge clk_i) begin
    assume(s_axis_tdata_i[7:1] == 'h0);
    assume(m_axis_tready_i == 1'b1);

end

always @(posedge clk_i) begin
    if (f_past_valid && $past(s_axis_tvalid_i && !s_axis_tready_o, 1)) begin
        assume($stable(s_axis_tdata_i));
    end
end

// COVER
//lets make sure one axi beat is transmitted
always @( posedge clk_i ) begin
  if (f_past_valid) begin
      cover(m_axis_tvalid_o);
  end
end


// ASSERTIONS
m_axis_assertions
  #(
    .C_AXIS_DATA_WIDTH(512))
m_axis_assertions (
    .aclk(        clk_i),
    .axis_tvalid( m_axis_tvalid_o),
    .axis_tready( m_axis_tready_i),
    .axis_tlast(  1'b1 ),
    .axis_tdata(  m_axis_tdata_o));



`endif

endmodule

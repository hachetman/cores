module uart # 
(parameter BAUD        = "HMAC-SHA1",
 parameter CLK_FREQ    = 160)
(
 input  wire         clk_i,
// AXI STREAM SLAVE INTERFACE
 input  wire [7:0] s_axis_tdata_i,
 input  wire         s_axis_tvalid_i,
 output reg          s_axis_tready_o,

// AXI STREAM MASTER INTERFACE
 output wire [7:0] m_axis_tdata_o,
 output wire         m_axis_tvalid_o,
 input  wire         m_axis_tready_i
);
endmodule

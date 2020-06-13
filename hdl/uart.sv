module uart # 
(parameter BAUD        = "HMAC-SHA1",
 parameter CLK_FREQ    = 160)
(
 input  wire         clk_i,
// AXI STREAM SLAVE INTERFACE
 input  wire [7:0]   s_axis_tdata_i,
 input  wire         s_axis_tvalid_i,
 output reg          s_axis_tready_o,

// AXI STREAM MASTER INTERFACE
 output wire [7:0] m_axis_tdata_o,
 output wire         m_axis_tvalid_o,
 input  wire         m_axis_tready_i
);


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
    assume(s_axis_tdata_i[511:1] == 'h0);
    assume(m_axis_tready_i == 1'b1);
end

always @(posedge clk_i) begin
    if (f_past_valid && $past(s_axis_tvalid_i && !s_axis_tready_o, 1)) begin
        assume($stable(s_axis_tdata_i));
    end
end

// COVER
//lets make sure one block is hashed
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

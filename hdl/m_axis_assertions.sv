`default_nettype none
module m_axis_assertions
#(
  parameter       C_AXIS_DATA_WIDTH = 128
)
(
 input  wire aclk,
 input  wire axis_tvalid,
 input  wire axis_tready,
 input  wire axis_tlast,
 input  wire [C_AXIS_DATA_WIDTH - 1 : 0] axis_tdata);


// Keep track of a flag telling us whether or not $past()
// will return valid results
reg f_past_valid;
initial	f_past_valid = 1'b0;
always @(posedge aclk)
	f_past_valid = 1'b1;


//AXI4STREAM_ERRM_TDEST_STABLE	TDEST remains stable when TVALID is asserted, and TREADY is LOW	Handshake process on Page 2-3
// TODO
// AXI4STREAM_ERRM_TDATA_STABLE	TDATA remains stable when TVALID is asserted, and TREADY is LOW	Handshake process on Page 2-3
// AXI4STREAM_ERRM_TLAST_STABLE	TLAST remains stable when TVALID is asserted, and TREADY is LOW	Handshake process on Page 2-3
reg hold_r;
reg [C_AXIS_DATA_WIDTH - 1 : 0] tdata_r;
reg tlast_r;
initial hold_r = 1'b0;
initial tdata_r = 'b0;
initial tlast_r = 1'b0;
always @(posedge aclk) begin
    hold_r <= axis_tvalid && !axis_tready;
    tdata_r <= axis_tdata;
    tlast_r <= axis_tlast;
    if (f_past_valid && hold_r) begin
        assert(tdata_r == axis_tdata);
        assert(tlast_r == axis_tlast);
    end
end

/*
// TODO AXI4STREAM_ERRM_TSTRB_STABLE	TSTRB remains stable when TVALID is asserted, and TREADY is LOW	Handshake process on Page 2-3
// TODO AXI4STREAM_ERRM_TKEEP_STABLE	TKEEP remains stable when TVALID is asserted, and TREADY is LOW	Handshake process on Page 2-3
// TODO AXI4STREAM_ERRM_TVALID_STABLE	When TVALID is asserted, then it must remain asserted until TREADY is HIGH	Handshake process on Page 2-3
// TODO AXI4STREAM_RECS_TREADY_MAX_WAIT	Recommended that TREADY is asserted within MAXWAITS cycles of TVALID being asserted	-
//AXI4STREAM_ERRM_TID_X	A value of X on TID is not permitted when TVALID is HIGH	-
//AXI4STREAM_ERRM_TDEST_X	A value of X on TDEST is not permitted when TVALID is HIGH	-
//AXI4STREAM_ERRM_TDATA_X	A value of X on TDATA is not permitted when TVALID is HIGH
//AXI4STREAM_ERRM_TSTRB_X	A value of X on TSTRB is not permitted when TVALID is HIGH	-
//AXI4STREAM_ERRM_TLAST_X	A value of X on TLAST is not permitted when TVALID is HIGH	-
//AXI4STREAM_ERRM_TKEEP_X	A value of X on TKEEP is not permitted when TVALID is HIGH	-
//AXI4STREAM_ERRM_TVALID_X	A value of X on TVALID is not permitted when not in reset	-
//AXI4STREAM_ERRS_TREADY_X	A value of X on TREADY is not permitted when not in reset	-
//AXI4STREAM_ERRM_TUSER_X	A value of X on TUSER is not permitted when not in reset	-
// TODO AXI4STREAM_ERRM_TUSER_STABLE	TUSER payload signals must remain constant while TVALID is asserted, and TREADY is de-asserted	Handshake process on Page 2-3
// AXI4STREAM_ERRM_STREAM_ALL_DONE_EOS	At the end of simulation/*
*/

endmodule
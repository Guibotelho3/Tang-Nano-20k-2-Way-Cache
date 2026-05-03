module mux(
    din_0,
    din_1,
    sel,
    mux_out
);
parameter bitsBlock = 2;
input  [bitsBlock-1:0] din_0;
input  [bitsBlock-1:0] din_1;
input  sel;
output [bitsBlock-1:0] mux_out;

assign mux_out = (sel) ? din_1 : din_0;

endmodule

module ram(clk, addr, din, wr, dout, reset);
parameter bitsRam = 5;
parameter ramSize = 32;

input  clk;
input  [bitsRam-1:0] addr;
input  [7:0] din;
input  wr;
output [7:0] dout;
input  reset;

reg [7:0] memory [0:ramSize-1];
reg [7:0] dout;

integer i;

always @(posedge clk)
    if (wr) memory[addr] <= din;

always @(*)
    dout <= memory[addr];

always @(posedge reset)
    for (i = 0; i < ramSize; i = i + 1)
        memory[i] <= i;

endmodule

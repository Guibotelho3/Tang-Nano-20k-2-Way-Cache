module datacache(clk, line, blk, din, wr, dout);
parameter bitsBlock     = 2;
parameter cacheLineBits = 1;
parameter cacheSize     = 16;

input  clk;
input  [cacheLineBits-1:0] line;
input  [bitsBlock-1:0] blk;
input  [7:0] din;
input  wr;
output [7:0] dout;

reg [7:0] memory [0:cacheSize-1];
reg [7:0] dout;

integer i;
initial
    for (i = 0; i < cacheSize; i = i + 1)
        memory[i] = 0;

always @(posedge clk)
    if (wr) memory[{line, blk}] <= din;

always @(*)
    dout <= memory[{line, blk}];

endmodule

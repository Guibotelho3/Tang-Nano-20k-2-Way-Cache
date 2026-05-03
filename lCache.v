(* syn_hier = "hard" *)
module lCache(clk, rst, line, data, wr, dout);
parameter cacheLineBits = 1;
parameter cacheLines    = 2;

input  clk;
input  [cacheLineBits-1:0] line;
input  data;
input  wr;
input  rst;
output dout;

reg memory [0:cacheLines-1] /* synthesis syn_ramstyle = "registers" */;
reg dout;

integer i;

initial
    for (i = 0; i < cacheLines; i = i + 1)
        memory[i] = 0;

always @(posedge clk) begin
    if (rst)
        for (i = 0; i < cacheLines; i = i + 1)
            memory[i] <= 0;
    else if (wr)
        memory[line] <= data;
end

always @(*)
    dout = memory[line];

endmodule

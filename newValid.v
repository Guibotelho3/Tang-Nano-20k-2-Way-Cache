module valid(clk, line, reset, wr, dout);
parameter cacheLineBits = 1;
parameter cacheLines    = 2;

input  clk;
input  [cacheLineBits-1:0] line;
input  reset;
input  wr;
output dout;

reg memory [0:cacheLines-1];
reg dout;

integer i;

// Inicializa em 0 na simulacao
initial
    for (i = 0; i < cacheLines; i = i + 1)
        memory[i] = 0;

always @(posedge clk) begin
    if (reset)
        for (i = 0; i < cacheLines; i = i + 1)
            memory[i] <= 0;
    else if (wr)
        memory[line] <= 1;
end

always @(*)
    dout = memory[line];

endmodule

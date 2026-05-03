(* syn_hier = "hard" *)
module Mtag(clk, line, din, wr, dout, reset);
parameter cacheLineBits = 1;
parameter bitsTag       = 2;
parameter cacheLines    = 2;

input  clk;
input  [cacheLineBits-1:0] line;
input  [bitsTag-1:0] din;
input  wr;
output [bitsTag-1:0] dout;
input  reset;

reg [bitsTag-1:0] memory [0:cacheLines-1] /* synthesis syn_ramstyle = "registers" */;
reg [bitsTag-1:0] dout;

integer i;

// Inicializa com valor impossivel de tag (todos 1s) para nao dar match falso
initial
    for (i = 0; i < cacheLines; i = i + 1)
        memory[i] = {bitsTag{1'b1}};

always @(posedge clk) begin
    if (reset)
        for (i = 0; i < cacheLines; i = i + 1)
            memory[i] <= {bitsTag{1'b1}};
    else if (wr)
        memory[line] <= din;
end

always @(*)
    dout <= memory[line];

endmodule

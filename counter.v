// Counter: conta de 0 a blockSize-1 enquanto reset=0
// reset=1 -> zera e para
// End=1 quando chegou no ultimo valor
module counter(out, clk, reset, End);
parameter bitsBlock = 2;
parameter blockSize = 4;

output reg [bitsBlock-1:0] out;
output reg End;
input clk, reset;

always @(posedge clk) begin
    if (reset) begin
        out <= 0;
        End <= 0;
    end else begin
        if (out == blockSize - 1) begin
            End <= 1;
            out <= 0;
        end else begin
            End <= 0;
            out <= out + 1;
        end
    end
end

endmodule

(* syn_hier = "hard" *)
module lru(input sel, input FSMv, input L, input And, output reg Lnew);
wire [2:0] x;
assign x = {FSMv, L, And};

always @* begin
    if (sel) begin
        case (x)
            3'b101: Lnew = 0;
            3'b111: Lnew = 0;
            3'b100: Lnew = 1;
            3'b110: Lnew = 1;
            default: Lnew = 0;
        endcase
    end else
        Lnew = L;
end
endmodule

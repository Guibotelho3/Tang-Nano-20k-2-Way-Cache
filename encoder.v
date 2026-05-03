module encoder(input [1:0] cv, output outmux, output hit);
assign hit   = cv[0] | cv[1];
assign outmux = ~cv[0] & cv[1] ? 1'b1 : 1'b0;
endmodule

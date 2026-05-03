(* syn_hier = "hard" *)
module comparator(out, tag, tag_in);
parameter bitsTag = 2;
output out;
input  [bitsTag-1:0] tag;
input  [bitsTag-1:0] tag_in;

assign out = (tag == tag_in) ? 1 : 0;

endmodule

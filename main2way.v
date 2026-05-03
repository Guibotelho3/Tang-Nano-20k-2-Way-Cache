// ============================================================
// Top-level: Cache 2-Way Read-Only
// Parâmetros ajustáveis conforme necessidade:
//   cacheSize  = tamanho total da cache (bytes, por via)
//   ramSize    = tamanho da RAM (bytes)
//   blockSize  = tamanho do bloco (bytes)
// ============================================================
module cache_2way_read_only #(
    parameter cacheSize     = 16,
    parameter ramSize       = 32,
    parameter blockSize     = 4,
    parameter cacheLines    = cacheSize / (2 * blockSize),
    parameter cacheLineBits = $clog2(cacheLines),
    parameter ramBits       = $clog2(ramSize),
    parameter blockBits     = $clog2(blockSize),
    parameter tagBits       = ramBits - blockBits - cacheLineBits
)(
    input  wire clk,
    input  wire reset,
    input  wire [ramBits-1:0] address,
    input  wire [7:0] din,
    output reg  [7:0] dout,
    output wire done,
    output wire hit
);

// --- Decomposição do endereço ---
wire [tagBits-1:0]       tag  = address[ramBits-1 : blockBits+cacheLineBits];
wire [cacheLineBits-1:0] line = address[blockBits+cacheLineBits-1 : blockBits];
wire [blockBits-1:0]     blk  = address[blockBits-1 : 0];

// --- Sinais FSM ---
wire Twr0, Dwr0, Twr1, Dwr1, Rwr, Cnt, MuxSel, Done, Fsm0, Fsm1, LruSel0, LruSel1;
wire END;
wire [1:0] c, v;

assign done = Done;

// --- Sinais internos ---
wire [7:0]          Ram2Cache;
wire [blockBits-1:0] Mux1, Muxout;
wire [tagBits-1:0]  Tout0, Tout1;
wire Lout0, Lout1, Lnew0, Lnew1;
wire [7:0] Cache2out0, Cache2out1;
wire outmuxencoder;
wire and0 = c[0] & v[0];
wire and1 = c[1] & v[1];

always @(*)
    dout = outmuxencoder ? Cache2out1 : Cache2out0;

// --- Instâncias ---
newFsm FSM(
    .clk(clk), .reset(reset),
    .c(c), .v(v),
    .lruSel0(LruSel0), .lruSel1(LruSel1),
    .l0(Lnew0), .l1(Lnew1),
    .END(END), .hit(hit),
    .Twr0(Twr0), .Dwr0(Dwr0),
    .Twr1(Twr1), .Dwr1(Dwr1),
    .Rwr(Rwr), .Cnt(Cnt),
    .Mux(MuxSel), .Done(Done),
    .Fsm0(Fsm0), .Fsm1(Fsm1)
);

valid #(cacheLineBits, cacheLines) V0(
    .clk(clk), .line(line), .reset(reset), .wr(Twr0), .dout(v[0]));

valid #(cacheLineBits, cacheLines) V1(
    .clk(clk), .line(line), .reset(reset), .wr(Twr1), .dout(v[1]));

Mtag #(cacheLineBits, tagBits, cacheLines) T0(
    .clk(clk), .line(line), .din(tag), .wr(Twr0), .dout(Tout0), .reset(reset));

(* syn_keep = "true" *) Mtag #(cacheLineBits, tagBits, cacheLines) T1(
    .clk(clk), .line(line), .din(tag), .wr(Twr1), .dout(Tout1), .reset(reset));

(* syn_keep = "true" *) comparator #(tagBits) comp0(.out(c[0]), .tag(tag), .tag_in(Tout0));
(* syn_keep = "true" *) comparator #(tagBits) comp1(.out(c[1]), .tag(tag), .tag_in(Tout1));

datacache #(blockBits, cacheLineBits, cacheSize) dcache0(
    .clk(clk), .line(line), .blk(Muxout), .din(Ram2Cache), .wr(Dwr0), .dout(Cache2out0));

datacache #(blockBits, cacheLineBits, cacheSize) dcache1(
    .clk(clk), .line(line), .blk(Muxout), .din(Ram2Cache), .wr(Dwr1), .dout(Cache2out1));

(* syn_keep = "true" *) lru LRU0(.sel(LruSel0), .FSMv(Fsm0), .L(Lout0), .And(and0), .Lnew(Lnew0));
(* syn_keep = "true" *) lru LRU1(.sel(LruSel1), .FSMv(Fsm1), .L(Lout1), .And(and1), .Lnew(Lnew1));

(* syn_keep = "true" *) lCache #(cacheLineBits, cacheLines) L0(
    .clk(clk), .rst(reset), .data(Lnew0), .line(line), .wr(Fsm0), .dout(Lout0));

(* syn_keep = "true" *) lCache #(cacheLineBits, cacheLines) L1(
    .clk(clk), .rst(reset), .data(Lnew1), .line(line), .wr(Fsm1), .dout(Lout1));

(* syn_keep = "true" *) encoder enc(.cv({and1, and0}), .outmux(outmuxencoder), .hit(hit));

ram #(ramBits, ramSize) R(
    .clk(clk), .addr({tag, line, Muxout}), .din(din), .wr(Rwr), .dout(Ram2Cache), .reset(reset));

mux #(blockBits) DataMux(
    .din_0(blk), .din_1(Mux1), .sel(MuxSel), .mux_out(Muxout));

counter #(blockBits, blockSize) count(
    .out(Mux1), .clk(clk), .reset(Cnt), .End(END));

endmodule

`include "main2way.v"
`include "newFsm.v"
`include "mux.v"
`include "ram.v"
`include "newValid.v"
`include "comparator.v"
`include "counter.v"
`include "newMtag.v"
`include "newDatacache.v"
`include "lCache.v"
`include "encoder.v"
`include "lru.v"

module tb_cache;

parameter cacheSize     = 16;
parameter ramSize       = 32;
parameter blockSize     = 4;
parameter cacheLines    = cacheSize / (2 * blockSize);
parameter cacheLineBits = $clog2(cacheLines);
parameter ramBits       = $clog2(ramSize);
parameter blockBits     = $clog2(blockSize);
parameter tagBits       = ramBits - blockBits - cacheLineBits;

reg  clk, reset;
reg  [ramBits-1:0] address;
reg  [7:0] din;
wire [7:0] dout;

cache_2way_read_only #(
    .cacheSize(cacheSize), .ramSize(ramSize), .blockSize(blockSize),
    .cacheLines(cacheLines), .cacheLineBits(cacheLineBits),
    .ramBits(ramBits), .blockBits(blockBits), .tagBits(tagBits)
) DUT (
    .clk(clk), .reset(reset), .address(address), .din(din), .dout(dout)
);

initial clk = 0;
always #5 clk = ~clk;

// Captura se foi hit ou miss ANTES de carregar o bloco
// (estado Miss = foi miss, ReadData direto = foi hit)
task access;
    input [ramBits-1:0] addr;
    input integer step;
    integer t;
    reg was_hit;
    reg [tagBits-1:0]       a_tag;
    reg [cacheLineBits-1:0] a_line;
    reg [blockBits-1:0]     a_blk;
    begin
        a_tag  = addr[ramBits-1 : blockBits+cacheLineBits];
        a_line = addr[blockBits+cacheLineBits-1 : blockBits];
        a_blk  = addr[blockBits-1 : 0];

        address = addr;

        // Espera FSM sair de ReadTag (processa o endereco)
        @(posedge clk); // ciclo em ReadTag avalia hit
        @(posedge clk); // agora esta em ReadData(hit) ou Miss(miss)

        // Captura resultado real: se foi direto para ReadData = HIT
        was_hit = (DUT.FSM.state == 4'b0001); // ReadData

        // Espera Done (ReadData)
        t = 0;
        while (!DUT.Done && t < 100) begin @(posedge clk); t = t + 1; end

        $display("-----------------------------------------------------");
        $display("Acesso #%0d  | Endereco = %0d  (%05b)", step, addr, addr);
        $display("  Decomposicao : TAG=%0d  LINHA=%0d  BLOCO=%0d", a_tag, a_line, a_blk);
        if (was_hit)
            $display("  Resultado    : HIT  -- dado ja estava na cache");
        else
            $display("  Resultado    : MISS -- bloco carregado da RAM");
        $display("  Dado lido    : %0d", dout);
        $display("  P0: V=%b  TAG=%0d  LRU=%b  |  P1: V=%b  TAG=%0d  LRU=%b",
                 DUT.V0.memory[a_line], DUT.T0.memory[a_line], DUT.L0.memory[a_line],
                 DUT.V1.memory[a_line], DUT.T1.memory[a_line], DUT.L1.memory[a_line]);
    end
endtask

initial begin
    $dumpfile("tb_cache.vcd");
    $dumpvars(0, tb_cache);

    din = 0; address = 0; reset = 1;
    #20; reset = 0; #10;

    $display("=====================================================");
    $display("  CACHE 2-WAY SET ASSOCIATIVE com LRU");
    $display("  Endereco: %0d bits | TAG:%0d | LINHA:%0d | BLOCO:%0d",
             ramBits, tagBits, cacheLineBits, blockBits);
    $display("  cacheLines=%0d | blockSize=%0d bytes", cacheLines, blockSize);
    $display("=====================================================");

    access(22, 0);  // MISS -> P0
    access(26, 1);  // MISS -> P0
    access(22, 2);  // HIT  P0
    access(26, 3);  // HIT  P0
    access(16, 4);  // MISS -> P1
    access( 3, 5);  // MISS -> substitui LRU
    access(16, 6);  // HIT
    access(18, 7);  // HIT ou MISS

    $display("=====================================================");
    $display("  FIM DA SIMULACAO");
    $display("=====================================================");
    $finish;
end

endmodule

module newFsm(
    input  wire clk, reset, END, hit, l0, l1,
    input  [1:0] v, c,
    output reg Twr0, Dwr0, Twr1, Dwr1, Rwr, Cnt, Mux, Done, Fsm0, Fsm1, lruSel0, lruSel1
);

reg [3:0] state;
reg first_cycle; // ignora END no primeiro ciclo de ReadBlk

parameter ReadTag    = 4'b0000,
          ReadData   = 4'b0001,
          ReadBlk0   = 4'b0010,
          UpdateTag0 = 4'b0011,
          EmptyP0    = 4'b0100,
          EmptyP1    = 4'b0101,
          Miss       = 4'b0110,
          ReadBlk1   = 4'b1010,
          UpdateTag1 = 4'b1011,
          OutOfCache = 4'b1111;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state      <= ReadTag;
        first_cycle <= 0;
    end else begin
        case (state)
            ReadTag:
                state <= hit ? ReadData : Miss;

            ReadData:
                state <= ReadTag;

            Miss:
                if      (~v[0])  state <= EmptyP0;
                else if (~v[1])  state <= EmptyP1;
                else             state <= OutOfCache;

            EmptyP0: begin
                state       <= ReadBlk0;
                first_cycle <= 1;
            end

            EmptyP1: begin
                state       <= ReadBlk1;
                first_cycle <= 1;
            end

            OutOfCache: begin
                state       <= l0 ? ReadBlk0 : (l1 ? ReadBlk1 : ReadBlk0);
                first_cycle <= 1;
            end

            ReadBlk0: begin
                first_cycle <= 0;
                if (END && !first_cycle) state <= UpdateTag0;
            end

            UpdateTag0: state <= ReadTag;

            ReadBlk1: begin
                first_cycle <= 0;
                if (END && !first_cycle) state <= UpdateTag1;
            end

            UpdateTag1: state <= ReadTag;

            default: state <= ReadTag;
        endcase
    end
end

always @(*) begin
    Cnt     = (state != ReadBlk0 && state != ReadBlk1);
    Twr0    = (state == UpdateTag0);
    Dwr0    = (state == ReadBlk0);
    Twr1    = (state == UpdateTag1);
    Dwr1    = (state == ReadBlk1);
    Rwr     = 0;
    Mux     = (state == ReadBlk0 || state == ReadBlk1);
    Done    = (state == ReadData);
    lruSel0 = (state == ReadData || state == UpdateTag0 || state == EmptyP0);
    lruSel1 = (state == ReadData || state == UpdateTag1 || state == EmptyP1);
    Fsm0    = (state != EmptyP0);
    Fsm1    = (state != EmptyP1);
end

endmodule

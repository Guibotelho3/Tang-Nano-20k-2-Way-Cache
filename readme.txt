Arquivo testado em simulação com testbench

iverilog -o sim tb_cache.v && vvp sim


A simulação está correta. Resumo do comportamento:

#0  addr=22  TAG=2 LINHA=1  MISS  -> carrega bloco em P0
#1  addr=26  TAG=3 LINHA=0  MISS  -> carrega bloco em P0
#2  addr=22  TAG=2 LINHA=1  HIT   -> P0 vira mais recente (LRU=0)
#3  addr=26  TAG=3 LINHA=0  HIT   -> P0 vira mais recente (LRU=0)
#4  addr=16  TAG=2 LINHA=0  MISS  -> linha 0 tem TAG=3 em P0, P1 vazia -> carrega P1
#5  addr=3   TAG=0 LINHA=0  MISS  -> ambas ocupadas, P0 é LRU=1 -> substitui P0
#6  addr=16  TAG=2 LINHA=0  HIT   -> ainda em P1
#7  addr=18  TAG=2 LINHA=0  HIT   -> mesmo bloco de addr=16
# Vending Machine em SystemVerilog

Projeto de uma máquina de venda automática descrita em SystemVerilog. O design acumula créditos a partir de moedas, verifica preço e estoque, libera o produto, calcula troco e permite cancelar a operação. O fluxo também inclui síntese lógica, inserção de scan chain e verificação formal de equivalência.

## Funcionalidades

- Quatro produtos selecionáveis por `item_sel`.
- Aceita moedas de 25, 50 e 100 centavos.
- Verifica crédito suficiente e disponibilidade em estoque.
- Libera o produto e decrementa o estoque após uma compra válida.
- Calcula e registra o troco da compra ou o crédito devolvido no cancelamento.
- Sinaliza erro para crédito insuficiente ou estoque esgotado.
- Disponibiliza o crédito atual e o estado da FSM para depuração.

## Arquitetura

O módulo de topo é `vending_top`, que integra:

- `control_unit`: FSM de controle da operação.
- `credit_reg`: acumulador de crédito e conversão das moedas para centavos.
- `memory`: memória síncrona de preços e estoque, com leitura combinacional.
- `comparator`: verifica se a venda pode ser realizada.
- `subtractor`: calcula o troco.
- `vending_pkg`: enumeração dos estados da FSM.

### Produtos iniciais

| `item_sel` | Produto | Preço | Estoque |
| --- | --- | ---: | ---: |
| `2'b00` | Café | 25 centavos | 5 |
| `2'b01` | Produto 1 | 50 centavos | 5 |
| `2'b10` | Produto 2 | 75 centavos | 3 |
| `2'b11` | Snack | 100 centavos | 2 |

O reset restaura esses valores.

### Interface de `vending_top`

| Sinal | Direção | Descrição |
| --- | --- | --- |
| `clk` | entrada | Clock principal, 50 MHz no cenário de síntese |
| `rst` | entrada | Reset síncrono, ativo em nível alto |
| `coin_insert` | entrada | Pulso que indica a inserção de uma moeda |
| `coin_in` | entrada | `00` = 0, `01` = 25, `10` = 50, `11` = 100 centavos |
| `buy_req` | entrada | Solicitação de compra |
| `item_sel` | entrada | Seleção de um dos quatro produtos |
| `cancel_req` | entrada | Cancela a operação e devolve o crédito |
| `dispense` | saída | Indica a liberação do produto |
| `change_out` | saída | Troco registrado, em centavos |
| `change` | saída | Troco combinacional, em centavos |
| `error` | saída | Indica falha na compra |
| `display` | saída | Crédito atual, em centavos |
| `state_out` | saída | Estado atual codificado em 3 bits |

### Estados

| Estado | Código | Função |
| --- | --- | --- |
| `IDLE` | `3'b000` | Aguarda a primeira moeda |
| `COLLECT` | `3'b001` | Acumula moedas e aguarda a compra |
| `CHECK` | `3'b010` | Verifica crédito e estoque |
| `DISPENSE` | `3'b011` | Libera o produto e reduz o estoque |
| `CHANGE` | `3'b100` | Registra o troco e encerra a compra |
| `ERROR` | `3'b101` | Aguarda cancelamento após uma falha |

## Estrutura do repositório

```text
rtl/       RTL SystemVerilog e pacote de estados
sim/       Testbench e cenários de simulação
synth/     Script, constraints e netlists de síntese
dft/       Script de inserção da cadeia de scan
fm/        Scripts e relatórios de equivalência RTL/netlist
fm_dft/    Script de equivalência entre netlists funcional e DFT
Makefile   Comandos principais do fluxo
```

## Pré-requisitos

A simulação exige ferramentas Synopsys instaladas:

- VCS (`vlogan`, `vcs` e `simv`)
- Verdi, para visualizar `waves.fsdb`
- Design Compiler (`dc_shell`)
- Formality, para verificação formal


## Simulação

A variável `RUN_SCENARIO` em `sim/tb_vending.sv` escolhe o cenário executado:

1. Compra bem-sucedida com troco.
2. Crédito insuficiente.
3. Cancelamento após inserir crédito.
4. Estoque zerado após cinco compras válidas.

Com o `RUN_SCENARIO` desejado configurado no testbench:

```bash
make syntax   # Verifica a sintaxe SystemVerilog
make compile  # Compila e elabora com VCS
make run      # Compila e executa o testbench
make wave     # Abre waves.fsdb no Verdi
```

A simulação gera mensagens `[PASS]` e `[FAIL]` no terminal e o arquivo `waves.fsdb` para análise temporal.

## Síntese

A síntese usa `synth/synth.tcl` e as constraints de `synth/vending.sdc`:

```bash
make synth
```

O script gera, entre outros, os seguintes artefatos:

- `synth/vending_top_netlist.v`
- `synth/vending_top_syn.v`
- `synth/vending_top_syn.ddc`
- `synth/reports/area_pos.rpt`
- `synth/reports/timing_relatorio.rpt`
- `synth/reports/power.rpt`
- `synth/reports/setup_violations.rpt`
- `synth/reports/default.svf`

As constraints configuram clock de 50 MHz, incerteza de 0,5 ns, atrasos de entrada e saída de 3 ns, fanout máximo de 8 e carga de saída de 0,05 pF.

## Inserção DFT

Após a síntese, o script `dft/dft_insert.tcl` configura uma cadeia de scan única com flip-flops multiplexados:

```bash
make dft
```

O fluxo realiza DRC antes e depois da inserção, gera preview, insere a cadeia, recompila incrementalmente e cria relatórios de cobertura, caminho de scan, área e timing. As portas de teste adicionadas são `scan_enable`, `scan_in` e `scan_out`.

Confira o caminho do netlist gerado pelo script antes de executar a etapa de equivalência DFT: o `write` do script grava `vending_top_netlist_scan.v` no diretório de trabalho do Design Compiler, enquanto `fm_dft/formality_dft.tcl` procura esse arquivo em `dft/`.

## Verificação formal

A equivalência RTL versus netlist sintetizada é conduzida pelo script `fm/formality.tcl`:

```bash
formality -f fm/formality.tcl
```

A equivalência entre a netlist funcional e a netlist com scan chain é conduzida por:

```bash
formality -f fm_dft/formality_dft.tcl
```

O script DFT força `scan_enable` para zero, restringindo a prova ao modo funcional. Antes de executar, ajuste em `fm_dft/formality_dft.tcl` o caminho da biblioteca indicado por `/caminho/da/biblioteca/typical.db` e confirme o local do netlist com scan.

Os relatórios de equivalência ficam nos diretórios `fm/reports/` e `fm_dft/reports/`, conforme o script utilizado.

## Limpeza

```bash
make clean_sim     # Remove artefatos de simulação
make clean_synth   # Remove artefatos de síntese
make clean         # Executa as duas limpezas
```

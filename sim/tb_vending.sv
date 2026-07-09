`timescale 1ns/1ps

module tb_vending;
  import vending_pkg::*;

  // 1. Geração de clock: always #5 clk = ~clk; (período 10 ns)
  logic clk;
  initial clk = 0;
  always #5 clk = ~clk;

  // Sinais de reset e controle do usuário
  logic       rst;
  logic       coin_insert;
  logic [1:0] coin_in;
  logic       buy_req;
  logic [1:0] item_sel;
  logic       cancel_req;
  
  // Saídas do sistema
  logic       dispense;
  logic       change_out;
  logic [7:0] change;
  logic       error;

  // Instanciação do DUT (Device Under Test)
  vending_top u_dut (
    .clk         (clk),
    .rst         (rst),
    .coin_insert (coin_insert),
    .coin_in     (coin_in),
    .buy_req     (buy_req),
    .item_sel    (item_sel),
    .cancel_req  (cancel_req),
    .dispense    (dispense),
    .change_out  (change_out),
    .change      (change),
    .error       (error)
  );

  // 5. Tarefa check(expected, actual, label) que reporta PASS/FAIL
  task check(input int expected, input int actual, input string label);
    if (expected === actual) begin
      $display("[PASS] %s", label);
    end else begin
      $display("[FAIL] %s - Esperado: %0d, Obtido: %0d", label, expected, actual);
    end
  endtask

  // 3. Tarefa apply_coin(value) que aplica uma moeda e aguarda 1 ciclo
  task apply_coin(input logic [1:0] value);
    @(negedge clk);
    coin_in = value;
    coin_insert = 1'b1;
    @(negedge clk);
    coin_insert = 1'b0;
    // Aguarda mais um ciclo para a FSM ir pro COLLECT e o registrador somar o crédito
    @(negedge clk);
    coin_in = 2'b00;
  endtask

  // 4. Tarefa buy_item(item, coins[]) que executa uma compra completa
  task buy_item(input logic [1:0] item, input logic [1:0] coins[]);
    // Aplica todas as moedas da lista
    foreach (coins[i]) begin
      apply_coin(coins[i]);
    end
    
    // Envia o comando de confirmar compra
    @(negedge clk);
    item_sel = item;
    buy_req = 1'b1;
    
    // Baixa o sinal no próximo ciclo
    @(negedge clk);
    buy_req = 1'b0;
  endtask

  // Tarefa auxiliar para resetar o DUT e isolar os cenários
  task reset_dut();
    rst = 1'b1;
    coin_insert = 1'b0;
    coin_in = 2'b00;
    buy_req = 1'b0;
    item_sel = 2'b00;
    cancel_req = 1'b0;
    repeat (2) @(negedge clk);
    rst = 1'b0;
    repeat (2) @(negedge clk);
  endtask

  // Sinais principais de teste e cenários
  initial begin
    // 6. Geração de waveform
    $dumpfile("vending.vcd");
    $dumpvars(0, tb_vending);

    // 2. Reset inicial por 2 ciclos de clock
    reset_dut();

    $display("\n=============================================");
    $display("           INICIANDO TESTES VENDING          ");
    $display("=============================================\n");

    // ---------------------------------------------------------
    // Cenário 1: Compra bem-sucedida com troco
    // coin_in=11 (R$1,00); sel_item=0 (café, R$0,25); confirm=1
    // Verificação esperada: dispense=1; change_out=75; credit=0 ao final
    // ---------------------------------------------------------
    $display("-> Cenario 1: Compra bem-sucedida (Cafe com R$ 1,00)");
    buy_item(2'b00, '{2'b11}); 
    
    // O pulso de buy_req abaixou. A FSM agora está em CHECK.
    // No próximo ciclo a FSM deve ir para DISPENSE
    @(negedge clk); 
    check(1, dispense, "Cenario 1: dispense=1 (DISPENSE)");
    
    // No próximo ciclo a FSM deve ir para CHANGE
    @(negedge clk); 
    check(1, change_out, "Cenario 1: change_out=1 (CHANGE)");
    check(75, change, "Cenario 1: troco correto de 75 centavos");
    
    // No próximo ciclo a FSM volta para IDLE e o crédito é zerado
    @(negedge clk);
    check(0, u_dut.u_credit_reg.credit, "Cenario 1: credit=0 ao final");
    check(3'b000, u_dut.w_current_state, "Cenario 1: FSM retornou a IDLE");
    
    repeat (3) @(negedge clk);

    // ---------------------------------------------------------
    // Cenário 2: Crédito insuficiente
    // coin_in=01 (R$0,25); sel_item=3 (snack, R$1,00); confirm=1
    // Verificação esperada: error=1; FSM vai para ERROR
    // ---------------------------------------------------------
    $display("\n-> Cenario 2: Credito insuficiente (Snack com R$ 0,25)");
    buy_item(2'b11, '{2'b01}); // sel_item=3 (snack)
    
    // FSM está em CHECK. No próximo ciclo vai para ERROR
    @(negedge clk); 
    check(1, error, "Cenario 2: error=1 ativado");
    check(3'b101, u_dut.w_current_state, "Cenario 2: FSM foi para ERROR (3'b101)");
    
    // Como a FSM retorna para IDLE diretamente (segundo o RTL), garantimos limpar o crédito
    cancel_req = 1'b1;
    @(negedge clk);
    cancel_req = 1'b0;
    repeat (2) @(negedge clk);

    // ---------------------------------------------------------
    // Cenário 3: Cancelamento
    // coin_in=11; coin_in=11; cancel=1
    // Verificação esperada: credit=0; FSM retorna a IDLE; change_out=200
    // ---------------------------------------------------------
    $display("\n-> Cenario 3: Cancelamento apos inserir R$ 2,00");
    apply_coin(2'b11); // Insere R$ 1,00
    apply_coin(2'b11); // Insere + R$ 1,00
    
    // Confere se acumulou 200 centavos
    @(negedge clk);
    check(200, u_dut.u_credit_reg.credit, "Cenario 3: Credito acumulado e de 200 centavos");
    
    // Pede cancelamento
    cancel_req = 1'b1;
    
    // NOTA: O comportamento de devolver o troco no cancelamento usando change_out=1
    // não foi implementado no RTL atual (que força o IDLE diretamente e zera o crédito).
    // O testbench irá falhar nesse check específico, reportando a inconsistência.
    check(1, change_out, "Cenario 3: change_out=1 no cancelamento");
    // Verificamos qual o valor de troco o subtrator apresenta
    check(200, change, "Cenario 3: devolve troco de 200 centavos");
    
    @(negedge clk);
    cancel_req = 1'b0;
    
    check(0, u_dut.u_credit_reg.credit, "Cenario 3: credit=0 apos cancel");
    check(3'b000, u_dut.w_current_state, "Cenario 3: FSM retornou a IDLE (3'b000)");

    repeat (3) @(negedge clk);

    // ---------------------------------------------------------
    // Cenário 4: Estoque zerado
    // Comprar café 5 vezes (estoque=5); tentar 6ª vez
    // Verificação esperada: Na 6ª vez: error=1 (stock=0)
    // ---------------------------------------------------------
    // Aplicamos reset para garantir que o estoque de café volte a 5, 
    // já que o Cenário 1 consumiu 1 café.
    reset_dut();
    
    $display("\n-> Cenario 4: Estoque zerado (Comprar cafe 5 vezes e falhar na 6a)");
    
    for (int i = 0; i < 5; i++) begin
      $display("   Comprando cafe %0d/5 (estoque restando)...", i+1);
      buy_item(2'b00, '{2'b11});
      
      // A FSM passa por: CHECK -> DISPENSE -> CHANGE -> IDLE
      // Esperamos esses ciclos para podermos fazer a proxima compra
      repeat(3) @(negedge clk); 
    end
    
    $display("   Tentando a 6a compra de cafe (deve falhar por falta de estoque)...");
    buy_item(2'b00, '{2'b11});
    
    // FSM em CHECK, avaliando estoque.
    @(negedge clk); 
    // FSM deve ir para ERROR porque stock chegou em 0.
    check(1, error, "Cenario 4: error=1 (stock=0 na 6a tentativa)");
    check(3'b101, u_dut.w_current_state, "Cenario 4: FSM foi para ERROR (3'b101)");
    
    repeat (5) @(negedge clk);
    
    $display("\n=============================================");
    $display("               TESTES CONCLUIDOS             ");
    $display("=============================================\n");
    $finish;
  end

endmodule

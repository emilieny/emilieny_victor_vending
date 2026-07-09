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
  logic [7:0] change_out;
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

  // Altere este valor para executar apenas um cenário por vez:
  // 1 = compra bem-sucedida, 2 = crédito insuficiente,
  // 3 = cancelamento, 4 = estoque zerado
  localparam int RUN_SCENARIO = 1;

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

  // Geração de waveform
  // Dump para waveform
  initial begin
      $fsdbDumpfile("waves.fsdb");
      $fsdbDumpvars(0, tb_vending);
  end


  // Sinais principais de teste e cenários
  initial begin
   

    // 2. Reset inicial por 2 ciclos de clock
    reset_dut();

    $display("\n=============================================");
    $display("           INICIANDO TESTES VENDING          ");
    $display("=============================================\n");

    if (RUN_SCENARIO == 1) begin
      // ---------------------------------------------------------
      // Cenário 1: Compra bem-sucedida com troco
      // coin_in=11 (R$1,00); sel_item=0 (café, R$0,25); confirm=1
      // Verificação esperada: dispense=1; change_out=75; credit=0 ao final
      // ---------------------------------------------------------
      $display("-> Cenario 1: Compra bem-sucedida (Cafe com R$ 1,00)");
      buy_item(2'b00, '{2'b11});

      @(negedge clk);
      check(1, dispense, "Cenario 1: dispense=1 (DISPENSE)");

      @(negedge clk);
      check(75, change_out, "Cenario 1: change_out=75 (CHANGE)");

      @(negedge clk);
      check(0, u_dut.u_credit_reg.credit, "Cenario 1: credit=0 ao final");
      check(3'b000, u_dut.state_out, "Cenario 1: FSM retornou a IDLE");
    end else if (RUN_SCENARIO == 2) begin
      // ---------------------------------------------------------
      // Cenário 2: Crédito insuficiente
      // coin_in=01 (R$0,25); sel_item=3 (snack, R$1,00); confirm=1
      // Verificação esperada: error=1; FSM vai para ERROR
      // ---------------------------------------------------------
      $display("\n-> Cenario 2: Credito insuficiente (Snack com R$ 0,25)");
      buy_item(2'b11, '{2'b01});

      @(negedge clk);
      check(1, error, "Cenario 2: error=1 ativado");
      check(3'b101, u_dut.w_current_state, "Cenario 2: FSM foi para ERROR (3'b101)");

      cancel_req = 1'b1;
      @(negedge clk);
      cancel_req = 1'b0;
      repeat (2) @(negedge clk);
    end else if (RUN_SCENARIO == 3) begin
      // ---------------------------------------------------------
      // Cenário 3: Cancelamento
      // coin_in=11; coin_in=11; cancel=1
      // Verificação esperada: credit=0; FSM retorna a IDLE; change_out=200
      // ---------------------------------------------------------
      $display("\n-> Cenario 3: Cancelamento apos inserir R$ 2,00");
      apply_coin(2'b11);
      apply_coin(2'b11);

      @(negedge clk);
      check(200, u_dut.u_credit_reg.credit, "Cenario 3: Credito acumulado e de 200 centavos");

      cancel_req = 1'b1;
      @(negedge clk);
      check(200, change_out, "Cenario 3: change_out=200 no cancelamento");

      cancel_req = 1'b0;
      @(negedge clk);

      check(0, u_dut.u_credit_reg.credit, "Cenario 3: credit=0 apos cancel");
      check(3'b000, u_dut.state_out, "Cenario 3: FSM retornou a IDLE (3'b000)");
    end else if (RUN_SCENARIO == 4) begin
      // ---------------------------------------------------------
      // Cenário 4: Estoque zerado
      // Comprar café 5 vezes (estoque=5); tentar 6ª vez
      // Verificação esperada: Na 6ª vez: error=1 (stock=0)
      // ---------------------------------------------------------
      reset_dut();

      $display("\n-> Cenario 4: Estoque zerado (Comprar cafe 5 vezes e falhar na 6a)");

      for (int i = 0; i < 5; i++) begin
        $display("   Comprando cafe %0d/5 (estoque restando)...", i+1);
        buy_item(2'b00, '{2'b11});
        repeat(3) @(negedge clk);
      end

      $display("   Tentando a 6a compra de cafe (deve falhar por falta de estoque)...");
      buy_item(2'b00, '{2'b11});

      @(negedge clk);
      check(1, error, "Cenario 4: error=1 (stock=0 na 6a tentativa)");
      check(3'b101, u_dut.state_out, "Cenario 4: FSM foi para ERROR (3'b101)");
    end else begin
      $display("Cenario invalido: %0d", RUN_SCENARIO);
    end

    repeat (5) @(negedge clk);
    
    $display("\n=============================================");
    $display("               TESTES CONCLUIDOS             ");
    $display("=============================================\n");
    $finish;
  end

endmodule

module vending_top
  import vending_pkg::*;
(
  input  logic       clk,
  input  logic       rst,
  
  // Entradas do usuário
  input  logic       coin_insert,
  input  logic [1:0] coin_in,     // 00 = 0, 01 = 25, 10 = 50, 11 = 100
  input  logic       buy_req,
  input  logic [1:0] item_sel,    // Seleção de 0 a 3
  input  logic       cancel_req,
  
  // Saídas do sistema
  output logic       dispense,
  output logic       change_out,
  output logic [7:0] change,
  output logic       error
);

  // Fios internos de interconexão (Datapath <-> Control)
  logic       w_can_sell;
  logic       w_credit_load;
  logic       w_mem_read;
  logic       w_mem_write;
  state_t     w_current_state;
  
  // Fios internos do Datapath
  logic [7:0] w_credit;
  logic [7:0] w_price;
  logic [7:0] w_stock;

  // Instanciação da Unidade de Controle
  control_unit u_control_unit (
    .clk           (clk),
    .rst           (rst),
    .coin_insert   (coin_insert),
    .buy_req       (buy_req),
    .cancel_req    (cancel_req),
    .can_sell      (w_can_sell),
    .credit_load   (w_credit_load),
    .mem_read      (w_mem_read),
    .mem_write     (w_mem_write),
    .dispense      (dispense),
    .change_out    (change_out),
    .error         (error),
    .current_state (w_current_state)
  );

  // Instanciação do Acumulador de Crédito
  credit_reg u_credit_reg (
    .clk           (clk),
    .rst           (rst),
    .cancel        (cancel_req),
    .credit_load   (w_credit_load),
    .current_state (w_current_state),
    .coin_in       (coin_in),
    .credit        (w_credit)
  );

  // Instanciação da Memória
  memory u_memory (
    .clk           (clk),
    .rst           (rst),
    .item_sel      (item_sel),
    .mem_read      (w_mem_read),
    .mem_write     (w_mem_write),
    .price         (w_price),
    .stock         (w_stock)
  );

  // Instanciação do Comparador
  comparator u_comparator (
    .credit        (w_credit),
    .price         (w_price),
    .stock         (w_stock),
    .can_sell      (w_can_sell)
  );

  // Instanciação do Subtrator de Troco
  subtractor u_subtrator (
    .credit        (w_credit),
    .price         (w_price),
    .change        (change)
  );

endmodule : vending_top

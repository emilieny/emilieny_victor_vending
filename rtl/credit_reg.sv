`timescale 1ns/1ps

module credit_reg
  import vending_pkg::state_t;
  import vending_pkg::COLLECT;
  import vending_pkg::CHANGE;
(
  input  logic        clk,
  input  logic        rst,          // reset sincrono, ativo alto
  input  logic        cancel,       // zera credito imediatamente
  input  logic        credit_load,  // pulso vindo da FSM
  input  state_t       current_state,
  input  logic [1:0]  coin_in,
  output logic [7:0]  credit
);

  // Conversao local de coin_in para centavos (ponto fixo, sem sinal).
  // 00 -> 0 | 01 -> 25 | 10 -> 50 | 11 -> 100
  function automatic logic [7:0] coin_value(input logic [1:0] coin_in);
    case (coin_in)
      2'b00:   coin_value = 8'd0;
      2'b01:   coin_value = 8'd25;
      2'b10:   coin_value = 8'd50;
      2'b11:   coin_value = 8'd100;
      default: coin_value = 8'd0;
    endcase
  endfunction

  always_ff @(posedge clk) begin
    if (rst || cancel) begin
      credit <= 8'd0;
    end
    else if (credit_load) begin
      unique case (current_state)
        COLLECT: credit <= credit + coin_value(coin_in);
        CHANGE:  credit <= 8'd0;
        default: credit <= credit; // credit_load so deveria vir ativo
                                    // nesses dois estados; mantem valor
                                    // em qualquer outro caso por seguranca
      endcase
    end
  end

endmodule : credit_reg
`timescale 1ns/1ps

module control_unit
  import vending_pkg::*;
(
  input  logic clk,
  input  logic rst,
  
  // Entradas do usuário
  input  logic coin_insert,
  input  logic buy_req,
  input  logic cancel_req,
  
  // Entrada do datapath
  input  logic can_sell,
  
  // Saídas de controle para o datapath
  output logic credit_load,
  output logic mem_read,
  output logic mem_write,
  
  // Saídas para o ambiente (usuário)
  output logic dispense,
  output logic change_valid,
  output logic error,
  
  // Estado atual (necessário para o credit_reg)
  output state_t current_state
);

  state_t state, next_state;
  
  assign current_state = state;

  // Bloco sequencial
  always_ff @(posedge clk) begin
    if (rst) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  // Bloco combinacional
  always_comb begin
    // Valores saídas 
    credit_load = 1'b0;
    mem_read    = 1'b0;
    mem_write   = 1'b0;
    dispense    = 1'b0;
    change_valid  = 1'b0;
    error       = 1'b0;
    next_state  = state;

    // Se houver cancelamento, devolvemos o troco e vamos para IDLE
    if (cancel_req) begin
      change_valid = 1'b1;
      next_state = IDLE;
    end else begin
      case (state)
      IDLE: begin
        if (coin_insert) begin
          credit_load = 1'b1;
          next_state = COLLECT;
        end
      end

      COLLECT: begin
        if (coin_insert) begin
          credit_load = 1'b1;
        end
        if (buy_req) begin
          next_state = CHECK;
        end
      end

      CHECK: begin
        mem_read = 1'b1;
        if (can_sell) begin
          next_state = DISPENSE;
        end else begin
          next_state = ERROR;
        end
      end

      DISPENSE: begin
        mem_read  = 1'b1;
        mem_write = 1'b1;
        dispense  = 1'b1;
        next_state = CHANGE;
      end

      CHANGE: begin
        mem_read  = 1'b1;
        change_valid = 1'b1;
        credit_load = 1'b1; 
        next_state = IDLE;
      end

      ERROR: begin
      // Permanece em ERROR aguardando o usuário apertar cancel_req
        error = 1'b1;
        next_state = ERROR;
      end

      default: next_state = IDLE;
      endcase
    end
  end

endmodule : control_unit

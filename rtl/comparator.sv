`timescale 1ns/1ps

module comparator (
  input  logic [7:0] credit,
  input  logic [7:0] price,
  input  logic [7:0] stock,
  output logic       can_sell
);
  // can_sell é verdadeiro  se o crédito for suficiente e houver estoque.
  assign can_sell = (credit >= price) && (stock > 8'd0);

endmodule : comparator

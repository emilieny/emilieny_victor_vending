`timescale 1ns/1ps

module subtractor (
  input  logic [7:0] credit,
  input  logic [7:0] price,
  input  logic       cancel_req,
  output logic [7:0] change
);

  // O subtrator calcula o troco o tempo inteiro,
  // no cancelamento ele devolve o valor total inserido.
  // se credit < price, retorna 0
  assign change = cancel_req ? credit : (credit >= price ? credit - price : 8'd0);

endmodule : subtractor

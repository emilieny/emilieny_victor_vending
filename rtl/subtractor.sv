`timescale 1ns/1ps

module subtractor (
  input  logic [7:0] credit,
  input  logic [7:0] price,
  input  logic       cancel_req,
  output logic [7:0] change
);

  // O subtrator é combinacional e calcula o troco o tempo todo,
  // mas no cancelamento ele devolve o valor total inserido.
  assign change = cancel_req ? credit : (credit - price);

endmodule : subtractor

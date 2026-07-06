module subtrator (
  input  logic [7:0] credit,
  input  logic [7:0] price,
  output logic [7:0] change
);

  // O subtrator é combinacional e calcula o troco o tempo todo,
  // mas seu resultado só é salvo pela FSM no estado CHANGE.
  assign change = credit - price;

endmodule : subtrator

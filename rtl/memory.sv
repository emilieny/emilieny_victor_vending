`timescale 1ns/1ps

module memory (
  input  logic        clk,
  input  logic        rst,
  input  logic [1:0]  item_sel,
  input  logic        mem_read,
  input  logic        mem_write,
  output logic [7:0]  price,
  output logic [7:0]  stock
);

  // Array de memória: 4 posições de 16 bits
  // Formato: [15:8] = preço, [7:0] = estoque
  logic [15:0] mem_array [0:3];



  always_ff @(posedge clk) begin
    if (rst) begin
      // Restaura os valores ao aplicar reset
      mem_array[0] <= {8'd25,  8'd5};
      mem_array[1] <= {8'd50,  8'd5};
      mem_array[2] <= {8'd75,  8'd3};
      mem_array[3] <= {8'd100, 8'd2};
    end else begin
      // Operação de escrita síncrona (decremento de estoque)
      if (mem_write) begin
        if (mem_array[item_sel][7:0] > 8'd0) begin
          mem_array[item_sel][7:0] <= mem_array[item_sel][7:0] - 8'd1;
        end
      end
    end
  end

  // Leitura combinacional para alinhar com a FSM de 6 estados (Moore)
  // price e stock estarão prontos no mesmo ciclo em que mem_read for 1
  always_comb begin
    if (mem_read) begin
      price = mem_array[item_sel][15:8];
      stock = mem_array[item_sel][7:0];
    end else begin
      price = 8'd0;
      stock = 8'd0;
    end
  end

endmodule : memory

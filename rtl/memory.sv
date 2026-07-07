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

  // Bloco initial para síntese em FPGA e simulação
  initial begin
    mem_array[0] = {8'd25,  8'd5};  // Item 0: R$ 0,25 (25 centavos), 5 no estoque
    mem_array[1] = {8'd50,  8'd10}; // Item 1: R$ 0,50 (50 centavos), 10 no estoque
    mem_array[2] = {8'd150, 8'd3};  // Item 2: R$ 1,50 (150 centavos), 3 no estoque
    mem_array[3] = {8'd200, 8'd8};  // Item 3: R$ 2,00 (200 centavos), 8 no estoque
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      // Restaura os valores ao aplicar reset
      mem_array[0] <= {8'd25,  8'd5};
      mem_array[1] <= {8'd50,  8'd10};
      mem_array[2] <= {8'd150, 8'd3};
      mem_array[3] <= {8'd200, 8'd8};
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

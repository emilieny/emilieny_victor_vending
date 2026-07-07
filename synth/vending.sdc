# ============================================================
# Clock principal
# ============================================================

# 10 ns -> 100 MHz
create_clock -name clk -period 10 [get_ports clk]

# Incerteza do clock
set_clock_uncertainty 0.1 [get_clocks clk]

# Tempo de subida/descida do clock
set_clock_transition 0.1 [get_clocks clk]

# ============================================================
# Input delay
# ============================================================
# Esse comando define o atraso de entrada para todos os sinais de entrada, exceto para o clock.
# O atraso é definido como 1.0 ns após a subida do clock, e o clock é removido da coleção
# de entradas usando o comando remove_from_collection.
set_input_delay 1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]

# ============================================================
# Output delay
# ============================================================
set_output_delay 1.0 -clock clk [all_outputs]

# ============================================================
# Fanout máximo
# ============================================================
set_max_fanout 8 [current_design]

# ============================================================
# Carga das saídas
# ============================================================
# Esse comando define a carga de saída para todos os sinais de saída.
# A carga é definida como 0.05 pF.
# Precisamos definir a carga de saída para garantir que o sintetizador possa
# otimizar corretamente o desempenho do circuito.
# Usada para modelar a capacitância externa ao seu circuito,
# como a capacitância de entrada de outros circuitos conectados às saídas.
set_load 0.05 [all_outputs]

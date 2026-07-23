# ============================================================
# Script de Síntese
# ============================================================

# ------------------------------------------------------------
# Carregar configuração
# ------------------------------------------------------------

set search_path [list . libs]
set target_library saed32rvt_tt1p05v25c.db
set synthetic_library dw_foundation.sldb
set link_library "* $target_library $synthetic_library"

# ------------------------------------------------------------
# Ler RTL
# ------------------------------------------------------------

analyze -format sverilog rtl/vending_pkg.sv
analyze -format sverilog rtl/comparator.sv
analyze -format sverilog rtl/subtractor.sv
analyze -format sverilog rtl/memory.sv
analyze -format sverilog rtl/control_unit.sv
analyze -format sverilog rtl/credit_reg.sv
analyze -format sverilog rtl/vending_top.sv

# ------------------------------------------------------------
# Elaborar
# ------------------------------------------------------------

elaborate vending_top

link

# ------------------------------------------------------------
# Constraints
# ------------------------------------------------------------

read_sdc synth/vending.sdc

# ------------------------------------------------------------
# Verificação do design
# ------------------------------------------------------------

puts "\n=================================================="
puts "CHECK DESIGN"
puts "=================================================="

file mkdir synth/reports
redirect synth/reports/check_design.rpt {
  check_design
}

# ------------------------------------------------------------
# Relatórios pré-síntese
# ------------------------------------------------------------

file mkdir synth/reports

redirect synth/reports/area_pre.rpt {
  report_area -hierarchy
}

redirect synth/reports/timing_pre.rpt {
  report_timing -max_paths 10
}

# ------------------------------------------------------------
# Síntese
# ------------------------------------------------------------

puts "\n=================================================="
puts "INICIANDO SÍNTESE"
puts "=================================================="

file mkdir synth/reports
set_svf synth/reports/default.svf

# A restrição de área DEVE vir antes do compile_ultra!
set_max_area 0

compile_ultra -no_autoungroup

# ------------------------------------------------------------
# Relatórios pós-síntese
# ------------------------------------------------------------

file mkdir synth/reports

redirect synth/reports/area_pos.rpt {
  report_area -hierarchy
}

redirect synth/reports/timing_relatorio.rpt {
  report_timing -max_paths 10
}

redirect synth/reports/power.rpt {
  report_power
}

redirect synth/reports/setup_violations.rpt {
  report_constraint -all_violators
}

# ------------------------------------------------------------
# Exportar netlist
# ------------------------------------------------------------

write -format verilog -hierarchy -output synth/vending_top_netlist.v
write -format verilog -hierarchy -output synth/vending_top_syn.v

write -format ddc -hierarchy -output synth/vending_top_syn.ddc

# ------------------------------------------------------------
# Salvar sessão do DC
# ------------------------------------------------------------

write_file -format ddc -hierarchy -output synth/vending_top.ddc

puts "\n=================================================="
puts "SÍNTESE CONCLUÍDA"
puts "=================================================="
puts "Arquivos gerados:"
puts "  synth/reports/area_pos.rpt"
puts "  synth/reports/timing_relatorio.rpt"
puts "  synth/reports/power.rpt"
puts "  synth/reports/setup_violations.rpt"
puts "  synth/reports/default.svf"
puts "  synth/vending_top_netlist.v"
puts "  synth/vending_top_syn.v"
puts "  synth/vending_top_syn.ddc"
puts "=================================================="

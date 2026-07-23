# ============================================================
# formality.tcl — Equivalência RTL (golden) x Netlist (revision)
# Controlador de Vending Machine — com guidance de SVF
# Rodar de dentro de fm/ :  fm_shell -f formality.tcl
# ============================================================

# 1. Biblioteca de células — a mesma target_library do synth.tcl
read_db -technology_library ../libs/saed32rvt_tt1p05v25c.db

# 2. ESSENCIAL: habilita o modo de setup automático baseado no SVF.
#    NESTA VERSAO (X-2025.06) tem que vir ANTES do set_svf,
#    senao da erro CMD-013 ("may not be changed after set_svf").
set synopsys_auto_setup true

# 3. Carrega o SVF gerado pelo Design Compiler (Etapa 1) como guidance.
#    Deve vir ANTES de qualquer read_verilog/set_top.
set_svf ../synth/reports/default.svf

# 4. Design de referência (golden) — RTL pré-síntese.
#    Mesma ordem de dependência do analyze no Design Compiler.
#    read_sverilog (nao read_verilog) para interpretar package/typedef enum.
read_sverilog -r { ../rtl/vending_pkg.sv \
                   ../rtl/credit_reg.sv \
                   ../rtl/memory.sv \
                   ../rtl/comparator.sv \
                   ../rtl/subtractor.sv \
                   ../rtl/control_unit.sv \
                   ../rtl/vending_top.sv }
set_top r:/WORK/vending_top

# 5. Design revisado — netlist gerada pelo Design Compiler.
#    OBS: a tua netlist chama vending_top_syn.v (nao vending_top_netlist.v).
read_verilog -i ../synth/vending_top_syn.v
set_top i:/WORK/vending_top

# 6. Casamento de pontos entre golden e revised, usando o guidance do SVF
match
report_svf_operation -status accepted > reports/formality_svf_accepted.rpt
report_svf_operation -status rejected > reports/formality_svf_rejected.rpt
report_matched_points                 > reports/formality_matched.rpt
report_unmatched_points               > reports/formality_unmatched.rpt

# 7. Prova de equivalência ponto a ponto
verify

# 8. Relatórios de sign-off
report_status          > reports/formality_status.rpt
report_passing_points   > reports/formality_passing.rpt
report_failing_points   > reports/formality_failing.rpt
report_unmatched_points > reports/formality_unmatched.rpt

exit

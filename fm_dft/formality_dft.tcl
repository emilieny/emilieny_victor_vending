# ============================================================
# formality_dft.tcl — Equivalência: netlist funcional (golden)
# x netlist com scan chain (revision)
# Controlador de Vending Machine
# ============================================================
# 1. Biblioteca de células — a mesma da síntese e da inserção de DFT
read_db /caminho/da/biblioteca/typical.db

# 2. (Opcional) SVF de guidance, se gerado na Etapa 5
# set_svf reports/default_dft.svf
# set synopsys_auto_setup true
# 3. Golden — netlist funcional, já provada equivalente ao RTL
read_verilog -r ../synth/vending_top_netlist.v
set_top r:/WORK/vending_top

# 4. Revision — netlist com scan chain
read_verilog -i ../dft/vending_top_netlist_scan.v
set_top i:/WORK/vending_top

# 5. Restringe a verificação ao modo funcional: scan_enable sempre 0
# do lado do revision, para que o mux de scan sempre selecione o
# dado funcional durante a prova.
set_constant i:/WORK/vending_top/scan_enable 0

# 6. Se a inserção tiver criado alguma lockup latch ou célula de
# teste sem correspondente possível no golden, exclua-a da prova
# explicitamente (ajuste o caminho ao nome real da instância):
# set_dont_verify_point i:/WORK/vending_top/lockup_latch_0
# 7. Casamento de pontos e prova
match
verify

# 8. Relatórios de sign-off
report_status -verbose > reports/formality_dft_status.rpt
report_unmatched_points > reports/formality_dft_unmatched.rpt
report_failing_points > reports/formality_dft_failing.rpt

exit
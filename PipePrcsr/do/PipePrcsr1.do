vsim work.pipeprcsr
add wave -position insertpoint  \
sim:/pipeprcsr/RST
add wave -position insertpoint  \
sim:/pipeprcsr/CLK
add wave -position insertpoint  \
sim:/pipeprcsr/IN_DATA
add wave -position insertpoint  \
sim:/pipeprcsr/OUT_DATA
add wave -position insertpoint  \
sim:/pipeprcsr/IF_Stage_inst/PC_inst/pc_out
add wave -position insertpoint  \
sim:/pipeprcsr/ID_inst/reg_file_inst/Reg
add wave -position insertpoint  \
sim:/pipeprcsr/ID_inst/EPC_inst/EPC_data
add wave -position insertpoint  \
sim:/pipeprcsr/EX_inst/Flags_reg_Inst/Flags_Out
add wave -position insertpoint  \
sim:/pipeprcsr/EX_inst/SP_Inc_Block_Inst/SP_Adrr

force -freeze sim:/pipeprcsr/RST 1 0
force -freeze sim:/pipeprcsr/CLK 1 0, 0 {500 ps} -r 1ns
force -freeze sim:/pipeprcsr/IN_DATA FFFF 0
run 1ns
force -freeze sim:/pipeprcsr/RST 0 0
run 28ns
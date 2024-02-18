`ifndef LEGACY_VERILOG
package sv_mon_pkg;
    `include "../tb/models/sv_mon_logic/sram_mon.sv"
    `include "../tb/models/sv_mon_logic/c2c_mon.sv"
    `include "../tb/models/sv_mon_logic/utilization_mon.sv"
endpackage
`else
    `include "../tb/models/sv_mon_logic/utilization_mon.sv"
`endif // LEGACY_VERILOG

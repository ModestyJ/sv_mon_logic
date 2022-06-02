`ifndef __sram_if
`define __sram_if

interface sram_sp_if#(int DATA_WIDTH=8, int ADDR_WIDTH=8)
    (   input clk, 
        input rstn,
        input [DATA_WIDTH-1:0] din,
        input [DATA_WIDTH-1:0] dout,
        input [ADDR_WIDTH-1:0] addr,
        input cs,
        input we,
        input oe,
        input layer_done
    );

    clocking cb@(posedge clk);
        input din;
        input dout;
        input addr;
        input cs;
        input we;
        input oe;
    endclocking
endinterface

interface sram_tp_if#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=8)
    (   input clk, 
        input rstn,
        input [DATA_WIDTH-1:0] din,
        input [DATA_WIDTH-1:0] dout,
        input [ADDR_WIDTH-1:0] addra,
        input [ADDR_WIDTH-1:0] addrb,
        input ena,
        input wea,
        input enb,
        input web,
        input layer_done
    );

    clocking cb@(posedge clk);
        input din;
        input dout;
        input addra;
        input addrb;
        input ena;
        input wea;
        input enb;
        input web;
    endclocking
endinterface

`endif

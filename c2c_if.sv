`ifndef __c2c_if
`define __c2c_if

interface c2c_if#(
    int DATA_WIDTH=32,
    int ADDR_WIDTH=32,
    int STRB_WIDTH=DATA_WIDTH/8
)(   
    input clk, 
    input rstn,
    input req,
    input [ADDR_WIDTH-1:0] addr,
    input [DATA_WIDTH-1:0] data,
    input [STRB_WIDTH-1:0] be,
    input we,
    input r_valid,
    input layer_done
);

    clocking cb@(posedge clk);
        input req;
        input addr;
        input data;
        input be;
        input we;
        input r_valid;
    endclocking
endinterface

`endif

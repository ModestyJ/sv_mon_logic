`ifndef __utilization_if
`define __utilization_if

interface utilization_if
    (   input clk, 
        input rstn,
        // conv
        input dataflow_en,
        input logic[8:0] conv_vld,
        // row-based
        input int w_row,
        input int h_row,
        input int ic_row,
        input int oc_row,
        input logic weight_req_row,
        // frame-based
        input int w_frame,
        input int h_frame,
        input int ic_frame,
        input int oc_frame,
        input logic weight_req_frame,
        input int weight_buf_sel_frame,
        input logic input_loader_rev_frame,
        input int input_buff_sel_frame,
        // input activation
        input logic input_loader_req,
        // layer
        input layer_start,
        input layer_done,
        input sim_done,
    );

    clocking cb@(posedge clk);
    endclocking
endinterface

`endif

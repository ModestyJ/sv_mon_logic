
`ifndef SYNTHESIS
`ifdef PROFILE
    import sv_mon_pkg::*;

    //////////////////////////////
    // SRAM MONITOR
    `define WEIGHT_BUFF_HIER cnn_accel_tb.u_cnn_accel.weight_buff
    sram_tp_if#(256, 8) sram_tp_if_weight_buff[Ti]();
    virtual sram_tp_if#(256, 8) virtual_sram_tp_if_weight_buff[Ti];

    generate
    for(genvar i=0; i<Ti; i=i+1) begin: weight_buff
        assign sram_tp_if_weight_buff[i].clk   = `WEIGHT_BUFF_HIER.gen_dpram[i].w_buffer.clk; 
        assign sram_tp_if_weight_buff[i].din   = `WEIGHT_BUFF_HIER.gen_dpram[i].w_buffer.dia; 
        assign sram_tp_if_weight_buff[i].dout  = `WEIGHT_BUFF_HIER.gen_dpram[i].w_buffer.dob; 
        assign sram_tp_if_weight_buff[i].addra = `WEIGHT_BUFF_HIER.gen_dpram[i].w_buffer.addra;
        assign sram_tp_if_weight_buff[i].addrb = `WEIGHT_BUFF_HIER.gen_dpram[i].w_buffer.addrb;
        assign sram_tp_if_weight_buff[i].ena   = `WEIGHT_BUFF_HIER.gen_dpram[i].w_buffer.ena; 
        assign sram_tp_if_weight_buff[i].wea   = `WEIGHT_BUFF_HIER.gen_dpram[i].w_buffer.wea; 
        assign sram_tp_if_weight_buff[i].enb   = `WEIGHT_BUFF_HIER.gen_dpram[i].w_buffer.enb; 
        assign sram_tp_if_weight_buff[i].web   = 1'b0;
        assign sram_tp_if_weight_buff[i].layer_done = layer_done;
    end
    endgenerate
    sram_mon_c#(256, 8) sram_mon_weight_buff[Ti];

    `define DRAM_HIER E_MEM
    sram_tp_if#(128, 22) sram_tp_if_dram(
        .clk   (`DRAM_HIER.clk),
        .din   (`DRAM_HIER.dia),
        .dout  (`DRAM_HIER.dob),
        .addra (`DRAM_HIER.addra),
        .addrb (`DRAM_HIER.addrb),
        .ena   (`DRAM_HIER.ena),
        .wea   (`DRAM_HIER.wea),
        .enb   (`DRAM_HIER.enb),
        .web   (1'b0),
        .layer_done   (layer_done)
    );
    sram_mon_c#(128, 22) sram_mon_dram;

    initial begin
        @(layer_start);
        fork
            begin: isolating_thread
                virtual_sram_tp_if_weight_buff = sram_tp_if_weight_buff[0:Ti-1];
                for(int i=0; i<Ti; i++) begin
                    fork
                        automatic int idx = i;
                    begin
                        sram_mon_weight_buff[idx] = new($sformatf("weight_buff%0d",idx));
                        sram_mon_weight_buff[idx].vif_tp = virtual_sram_tp_if_weight_buff[idx];
                        sram_mon_weight_buff[idx].run();
                    end
                    join_none
                end
            end: isolating_thread
            begin
                sram_mon_dram = new("dram");
                sram_mon_dram.vif_tp = sram_tp_if_dram;
                sram_mon_dram.run();
            end
        join_none
    end

    //////////////////////////////
    // UTILIZATION MONITOR
    utilization_if util_if(
        .clk                    (clk),
        // conv
        .dataflow_en            (dataflow_en),
        .conv_vld               (u_cnn_accel.gen_conv_kernel[0].convkernel_top.convkernel.accum_vld),
        // row-based
        .w_row                  (u_cnn_accel.u_cnn_fsm.x_rd),
        .h_row                  (u_cnn_accel.u_cnn_fsm.y_rd),
        .ic_row                 (u_cnn_accel.u_cnn_fsm.in_acc_cnt),
        .oc_row                 (u_cnn_accel.u_cnn_fsm.out_acc_cnt),
        .weight_req_row         (u_cnn_accel.u_cnn_fsm.winit_en_o),
        // frame-based
        .w_frame                (u_cnn_accel.cnnfsm_frame.x_rd),
        .h_frame                (u_cnn_accel.cnnfsm_frame.y_rd),
        .ic_frame               (u_cnn_accel.cnnfsm_frame.in_acc_cnt),
        .oc_frame               (u_cnn_accel.cnnfsm_frame.out_acc_cnt),
        .weight_req_frame       (u_cnn_accel.cnnfsm_frame.weight_rden_o),
        .weight_buf_sel_frame   (u_cnn_accel.cnnfsm_frame.weight_wsel_o),
        .input_loader_rev_frame (u_cnn_accel.cnnfsm_frame.inframe_rev),
        .input_buff_sel_frame   (u_cnn_accel.buff_sel_in),
        // input activation
        .input_loader_req       (u_cnn_accel.input_loader.down_req),
        // layer
        .layer_start            (layer_start),
        .is_last_layer          (is_last_layer), // Check simulation end condition
        .layer_done             (layer_done)
    );
    utilization_mon_c util_mon;

    initial begin
        @(layer_start);
        util_mon = new("profile");
        util_mon.vif = util_if;
        util_mon.run();
    end
    
`endif // PROFILE
`endif // SYNTHESIS

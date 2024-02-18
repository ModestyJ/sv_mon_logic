`ifndef __utilization_mon
`define __utilization_mon

///////////////  Choose one of cname to color the events //////////////////
//      < color name >    =           < cname >            //  < R, G, B >
//    colorLightMauve     = "thread_state_uninterruptible" // 182, 125, 143
//    colorOrange         = "thread_state_iowait"          // 255, 140, 0
//    colorSeafoamGreen   = "thread_state_running"         // 126, 200, 148
//    colorVistaBlue      = "thread_state_runnable"        // 133, 160, 210
//    colorTan            = "thread_state_unknown"         // 199, 155, 125
//    colorIrisBlue       = "background_memory_dump"       // 0, 180, 180
//    colorMidnightBlue   = "light_memory_dump"            // 0, 0, 180
//    colorDeepMagenta    = "detailed_memory_dump"         // 180, 0, 180
//    colorBlue           = "vsync_highlight_color"        // 0, 0, 255
//    colorGrey           = "generic_work"                 // 125, 125, 125
//    colorGreen          = "good"                         // 0, 125, 0
//    colorDarkGoldenrod  = "bad"                          // 180, 125, 0
//    colorPeach          = "terrible"                     // 180, 0, 0
//    colorWhite          = "white"                        // 255, 255, 255
//    colorYellow         = "yellow"                       // 255, 255, 0
//    colorOlive          = "olive"                        // 100, 100, 0
//    colorCornflowerBlue = "rail_response"                // 67, 135, 253
//    colorSunsetOrange   = "rail_animation"               // 244, 74, 63
//    colorTangerine      = "rail_idle"                    // 238, 142, 0
//    colorShamrockGreen  = "rail_load"                    // 13, 168, 97
//    colorGreenishYellow = "startup"                      // 230, 230, 0
//    colorTawny          = "heap_dump_child_node_arrow"   // 204, 102, 0
//    colorLemon          = "cq_build_running"             // 255, 255, 119
//    colorLime           = "cq_build_passed"              // 153, 238, 102
//    colorPink           = "cq_build_failed"              // 238, 136, 136
//    colorSilver         = "cq_build_abandoned"           // 187, 187, 187
//    colorManzGreen      = "cq_build_attempt_runnig"      // 222, 222, 75
//    colorKellyGreen     = "cq_build_attempt_passed"      // 108, 218, 35
///////////////////////////////////////////////////////////////////////////

`ifdef LEGACY_VERILOG
module utilization_mon (utilization_if vif); 
`else
class utilization_mon_c;
    virtual utilization_if vif;
`endif // LEGACY_VERILOG

    // monitoring variables
    int pid; // row-based:0, frame-based:1, layer_event:2
    int tid; // compute_op:1, memory_op_input_act:2, memory_op_model_param:3
    int w,h,ic,oc; // input act width position, height position, input channel position, output channel position
    int fd;
    realtime ts_conv, ts_act, ts_act_frame, ts_weight, ts_layer, ts_eltwise, ts_dma, ts_pdma, ts_weight_dma;
    realtime dur_conv, dur_act, dur_act_frame, dur_weight, dur_layer, dur_eltwise, dur_dma, dur_pdma, dur_weight_dma;
    typedef enum {conv, mem_input_act, mem_weight, layer, eltwise, dma, pdma, weight_dma} e_category;
    e_category cat;
    int num_layer;

`ifdef LEGACY_VERILOG
    string name = "profile";
    initial begin
        num_layer = 0;
    end
`else
    string name;

    function new(string name);
        this.num_layer = 0;
        this.name      = name;
    endfunction
`endif // LEGACY_VERILOG

    task run();
        $timeformat(-9); // time unit: ns
        if(vif!=null) begin
            fd = $fopen({"./report/",name,".json"}, "w");
            if(!fd) $fatal("file open error");

            $fdisplay(fd, "{");
            $fdisplay(fd, "\t\"displayTimeUnit\": \"ns\",");
            $fdisplay(fd, "\t\"traceEvents\": [");
            // Mapping pid, tid name for readability {
            $fdisplay(fd, "\t\t{\"name\": \"process_labels\", \"ph\": \"M\", \"pid\": 0, \"args\": {\"labels\": \"0.Row-based\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 0, \"tid\": 1, \"args\": {\"name\": \"4.Convolution\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 0, \"tid\": 2, \"args\": {\"name\": \"3.DRAM to L1 Act Copy\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 0, \"tid\": 3, \"args\": {\"name\": \"1.CDMA\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 0, \"tid\": 4, \"args\": {\"name\": \"5.Elemwise Add\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 0, \"tid\": 5, \"args\": {\"name\": \"6.Output Write\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 0, \"tid\": 6, \"args\": {\"name\": \"7.PDMA\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 0, \"tid\": 7, \"args\": {\"name\": \"2.Weight Fetch\"} },");

            $fdisplay(fd, "\t\t{\"name\": \"process_labels\", \"ph\": \"M\", \"pid\": 1, \"args\": {\"labels\": \"1.Frame-based\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 1, \"tid\": 1, \"args\": {\"name\": \"3.Convolution\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 1, \"tid\": 2, \"args\": {\"name\": \"1.CDMA\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 1, \"tid\": 3, \"args\": {\"name\": \"2.DRAM to L2 Weight Copy\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 1, \"tid\": 4, \"args\": {\"name\": \"4.Elemwise Add\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 1, \"tid\": 5, \"args\": {\"name\": \"5.Output Write\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 1, \"tid\": 6, \"args\": {\"name\": \"6.PDMA\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 1, \"tid\": 7, \"args\": {\"name\": \"7.Weight Fetch\"} },");

            $fdisplay(fd, "\t\t{\"name\": \"process_labels\", \"ph\": \"M\", \"pid\": 2, \"args\": {\"labels\": \"Layer\"} },");
            $fdisplay(fd, "\t\t{\"name\": \"thread_name\", \"ph\": \"M\", \"pid\": 2, \"tid\": 0, \"args\": {\"name\": \"Layer\"} },");
            // Mapping pid, tid name for readability }

            fork
                forever begin: conv_compute
                    @(posedge |vif.conv_vld)
                    if(vif.dataflow_en==0) begin // row-based
                        w = vif.w_row;
                        h = vif.h_row;
                        ic = vif.ic_row;
                        oc = vif.oc_row;
                    end
                    else begin // frame-based
                        w = vif.w_frame;
                        h = vif.h_frame;
                        ic = vif.ic_frame;
                        oc = vif.oc_frame;
                    end

                    ts_conv = $time/1000.0;

                    @(negedge |vif.conv_vld)
                    dur_conv = ($time/1000.0 - ts_conv);
                    cat = conv;
                    $fdisplay(fd, "\t\t{\"name\": \"CONV(row%0d_ic%0d_oc%0d)\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 1, \"ts\": %.3f, \"dur\": %.3f, \"cname\": %s},", h, ic, oc, cat.name(), vif.dataflow_en, ts_conv, dur_conv, "\"thread_state_iowait\"");

                end

                forever begin: mem_copy_activation
                    @(posedge vif.input_loader_req)
                    ts_act = $time/1000.0;

                    if(vif.dataflow_en==0) begin // row-based
                        @(negedge vif.input_loader_req)
                        dur_act = ($time/1000.0 - ts_act);
                        cat = mem_input_act;
                        $fdisplay(fd, "\t\t{\"name\": \"IFM_from_DRAM_to_buffer(row%0d)\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 2, \"ts\": %.3f, \"dur\": %.3f, \"cname\": %s},", vif.h_row+1, cat.name(), vif.dataflow_en, ts_act, dur_act, "\"detailed_memory_dump\"");
                    end
                end

                forever begin: mem_copy_activation_frame
                    @(posedge vif.input_loader_rev_frame)
                    ts_act_frame = $time/1000.0;

                    if(vif.dataflow_en==1) begin // frame-based
                        @(negedge vif.input_loader_rev_frame)
                        dur_act_frame = ($time/1000.0 - ts_act_frame);
                        cat = mem_input_act;
                        $fdisplay(fd, "\t\t{\"name\": \"IFM_from_DRAM_to_buffer(entire_frame)\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 2, \"ts\": %.3f, \"dur\": %.3f, \"cname\": %s},", cat.name(), vif.dataflow_en, ts_act_frame, dur_act_frame, "\"detailed_memory_dump\"");
                    end
                end

                forever begin: mem_copy_weight
                    @(posedge vif.weight_req_row, posedge vif.weight_req_frame);
                    if(vif.dataflow_en==0) begin // row-based
                        ts_weight = $time/1000.0;

                        @(negedge vif.weight_req_row)
                        dur_weight = ($time/1000.0 - ts_weight);

                        cat = mem_weight;
                        $fdisplay(fd, "\t\t{\"name\": \"Weight_from_DRAM_to_paramload(row%0d)\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 3, \"ts\": %.3f, \"dur\": %.3f, \"cname\": %s},", vif.h_row, cat.name(), vif.dataflow_en, ts_weight, dur_weight, "\"good\"");
                    end
                    else begin // frame-based
                        ts_weight = $time/1000.0;

                        @(negedge vif.weight_req_frame)
                        dur_weight = ($time/1000.0 - ts_weight);

                        cat = mem_weight;
                        $fdisplay(fd, "\t\t{\"name\": \"Weight_from_DRAM_to_weight_buff(%0d)\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 3, \"ts\": %.3f, \"dur\": %.3f, \"cname\": %s},", vif.weight_buf_sel_frame, cat.name(), vif.dataflow_en, ts_weight, dur_weight, "\"good\"");
                    end
                end

                forever begin: elt_wise_addition
                    @(posedge vif.elt_wise_en)
                    ts_eltwise = $time/1000.0;
                    @(negedge vif.elt_wise_en)
                    dur_eltwise = ($time/1000.0 - ts_eltwise);
                    cat = eltwise;
                    $fdisplay(fd, "\t\t{\"name\": \"Element-wise_addition\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 4, \"ts\": %.3f, \"dur\": %.3f, \"cname\": %s},", cat.name(), vif.dataflow_en, ts_eltwise, dur_eltwise, "\"olive\"");
                end

                forever begin: mem_copy_ofm
                    @(posedge vif.dma_start)
                    ts_dma = $time/1000.0;
                    @(negedge vif.dma_last)
                    dur_dma = ($time/1000.0 - ts_dma);
                    cat = dma;
                    $fdisplay(fd, "\t\t{\"name\": \"OFM_from_buffer_to_DRAM\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 5, \"ts\": %.3f, \"dur\": %.3f, \"cname\": %s},", cat.name(), vif.dataflow_en, ts_dma, dur_dma, "\"background_memory_dump\"");
                end

                forever begin: mem_copy_pdma
                    @(posedge vif.pdma_start)
                    ts_pdma = $time/1000.0;
                    @(negedge vif.pdma_last)
                    dur_pdma = ($time/1000.0 - ts_pdma);
                    cat = pdma;
                    $fdisplay(fd, "\t\t{\"name\": \"PDMA\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 6, \"ts\": %.3f, \"dur\": %.3f, \"cname\": %s},", cat.name(), vif.dataflow_en, ts_pdma, dur_pdma, "\"detailed_memory_dump\"");
                end

                forever begin: weight_copy_dma
                    @(posedge (!vif.clk & vif.weight_dma_start))
                    ts_weight_dma = $time/1000.0;
                    @(negedge vif.weight_dma_last)
                    dur_weight_dma = ($time/1000.0 - ts_weight_dma);
                    cat = weight_dma;
                    $fdisplay(fd, "\t\t{\"name\": \"Weight Fetch\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 7, \"ts\": %.3f, \"dur\": %.3f, \"cname\": %s},", cat.name(), vif.dataflow_en, ts_weight_dma, dur_weight_dma, "\"good\"");
                end

                forever begin: layer_seq
                    @(posedge vif.layer_start)
                    ts_layer = $time/1000.0;
                    @(posedge vif.layer_done)
                    dur_layer = ($time/1000.0 - ts_layer);
                    cat = layer;
                    $fdisplay(fd, "\t\t{\"name\": \"Layer%0d\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": 2, \"tid\": 0, \"ts\": %.3f, \"dur\": %.3f},", num_layer, cat.name(), ts_layer, dur_layer);
                    num_layer++;
                end

                forever begin: sim_done
                    @(posedge vif.sim_done)
                    $fdisplay(fd, "\t\t{}");
                    $fdisplay(fd, "\t]");
                    $fdisplay(fd, "}");
                    $fclose(fd);
                end
            join

        end else begin
            $fatal("%m vif is null", );
        end
        
    endtask

`ifdef LEGACY_VERILOG
endmodule
`else
endclass
`endif // LEGACY_VERILOG

`endif // __utilization_mon

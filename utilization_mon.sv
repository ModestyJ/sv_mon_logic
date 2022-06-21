`ifndef __utilization_mon
`define __utilization_mon

class utilization_mon_c;
    virtual utilization_if vif;

    // monitoring variables
    int pid; // row-based:0, frame-based:1, layer_event:2
    int tid; // compute_op:1, memory_op_input_act:2, memory_op_model_param:3
    int w,h,ic,oc; // input act width position, height position, input channel position, output channel position
    int num_layer;
    int fd;
    time ts_conv, ts_act, ts_weight, ts_layer;
    time dur_conv, dur_act, dur_weight, dur_layer;
    typedef enum {conv, mem_input_act, mem_weight, layer} e_category;
    e_category cat;
    string name;

    function new(string name);
        this.num_layer = 0;
        this.name      = name;
    endfunction

    task run();
        $timeformat(-9); // time unit: ns
        if(vif!=null) begin
            fd = $fopen({"./report/",name,".json"}, "w");
            if(!fd) $fatal("file open error");

            $fdisplay(fd, "{");
            $fdisplay(fd, "\t\"traceEvents\": [");

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

                    ts_conv = $time;

                    @(negedge |vif.conv_vld)
                    dur_conv = $time - ts_conv;
                    cat = conv;
                    $fdisplay(fd, "\t\t{\"name\": \"conv_row%0d_ic%0d_oc%0d\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 1, \"ts\": %t, \"dur\": %t},", h, ic, oc, cat.name(), vif.dataflow_en, ts_conv, dur_conv);

                end

                forever begin: mem_copy_activation
                    @(posedge vif.input_loader_req)
                    ts_act = $time;

                    if(vif.dataflow_en==0) begin // row-based
                        @(negedge vif.input_loader_req)
                        dur_act = $time - ts_act;
                        cat = mem_input_act;
                        $fdisplay(fd, "\t\t{\"name\": \"input_act_copy_from_dram_to_buffer_row%0d\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 2, \"ts\": %t, \"dur\": %t},", vif.h_row+1, cat.name(), vif.dataflow_en, ts_act, dur_act);
                    end
                    else begin // frame-based
                        @(negedge vif.input_loader_rev_frame)
                        dur_act = $time - ts_act;
                        cat = mem_input_act;
                        $fdisplay(fd, "\t\t{\"name\": \"input_act_copy_from_dram_to_buffer%0d_entire_frame(double_buff)\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 2, \"ts\": %t, \"dur\": %t},", vif.input_buff_sel_frame, cat.name(), vif.dataflow_en, ts_act, dur_act);
                    end
                end

                forever begin: mem_copy_weight
                    @(posedge vif.weight_req_row, posedge vif.weight_req_frame);
                    if(vif.dataflow_en==0) begin // row-based
                        ts_weight = $time;

                        @(negedge vif.weight_req_row)
                        dur_weight = $time - ts_weight;

                        cat = mem_weight;
                        $fdisplay(fd, "\t\t{\"name\": \"weight_copy_from_dram_to_paramload_row%0d\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 3, \"ts\": %t, \"dur\": %t},", vif.h_row, cat.name(), vif.dataflow_en, ts_weight, dur_weight);
                    end
                    else begin // frame-based
                        ts_weight = $time;

                        @(negedge vif.weight_req_frame)
                        dur_weight = $time - ts_weight;

                        cat = mem_weight;
                        $fdisplay(fd, "\t\t{\"name\": \"weight_copy_from_dram_to_weight_buff(double_buff%0d)\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": %d, \"tid\": 3, \"ts\": %t, \"dur\": %t},", vif.weight_buf_sel_frame, cat.name(), vif.dataflow_en, ts_weight, dur_weight);
                    end
                end

                forever begin: layer_seq
                    @(posedge vif.layer_start)
                    ts_layer = $time;
                    @(posedge vif.layer_done)
                    dur_layer = $time - ts_layer;
                    cat = layer;
                    if(vif.is_last_layer) begin
                        $fdisplay(fd, "\t\t{\"name\": \"layer%0d\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": 2, \"tid\": 0, \"ts\": %t, \"dur\": %t}", num_layer, cat.name(), ts_layer, dur_layer);
                        $fdisplay(fd, "\t\]");
                        $fdisplay(fd, "}");
                        $fclose(fd);
                    end else begin
                        $fdisplay(fd, "\t\t{\"name\": \"layer%0d\", \"cat\": \"%0s\", \"ph\": \"X\", \"pid\": 2, \"tid\": 0, \"ts\": %t, \"dur\": %t},", num_layer, cat.name(), ts_layer, dur_layer);
                        num_layer++;
                    end
                end
            join

        end else begin
            $fatal("%m vif is null", );
        end
        
    endtask

endclass

`endif

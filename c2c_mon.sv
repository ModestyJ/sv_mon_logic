`ifndef __c2c_mon
`define __c2c_mon

// `define TRACE_ALL

class c2c_mon_c #(
    int DATA_WIDTH=32,
    int ADDR_WIDTH=32,
    int STRB_WIDTH=DATA_WIDTH/8
);   
    virtual c2c_if#(DATA_WIDTH, ADDR_WIDTH, STRB_WIDTH) vif;

    // monitoring variables
    int cnt_read;
    int cnt_write;
    int num_layer;
    int fd;
    string name;
    logic [ADDR_WIDTH-1:0] temp_read_addr;

    function new(string name);
        this.cnt_read  = 0;
        this.cnt_write = 0;
        this.num_layer = 0;
        this.name      = name;
    endfunction

    task run();
        if(vif!=null) begin
            fd = $fopen({"./report/",name,".txt"}, "w");
            if(!fd) $fatal("file open error");

            fork
                forever begin: port
                    @(vif.cb.req)
                    if(vif.cb.we==0) begin
                        `ifdef TRACE_ALL
                        $fdisplay(fd, "[WR]addr:0x%0h, data:0x%0h", vif.cb.addr, vif.cb.data);
                        `endif
                        cnt_write++;
                    end else begin
                        `ifdef TRACE_ALL
                        @(vif.cb.r_valid)
                        $fdisplay(fd, "[RD]addr:0x%0h, data:0x%0h", vif.cb.addr, vif.cb.data);
                        `endif
                        cnt_read++;
                    end
                end
                forever begin: clear_sp
                    @(vif.layer_done)
                    cnt_write = 0;
                    cnt_read = 0;
                    $fdisplay(fd, "layer%0d, W:%0d bytes, R:%0d bytes", num_layer, cnt_write*(DATA_WIDTH/8), cnt_read*(DATA_WIDTH/8));
                    num_layer++;
                end
            join

            $fclose(fd);
        end else begin
            /* $warning("%m vif is null", ); */
            $fatal("%m vif is null", );
        end
        
    endtask

endclass

`endif

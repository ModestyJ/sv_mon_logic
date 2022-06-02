`ifndef __sram_mon
`define __sram_mon

`define TRACE_ALL

class sram_mon_c #(int DATA_WIDTH=8, int ADDR_WIDTH=8);
    virtual sram_sp_if#(DATA_WIDTH, ADDR_WIDTH) vif_sp;
    virtual sram_tp_if#(DATA_WIDTH, ADDR_WIDTH) vif_tp;

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
        if(vif_sp!=null) begin
            fd = $fopen({"./report/",name,".txt"}, "w");
            if(!fd) $fatal("file open error");

            fork
                forever begin: port
                    @(vif_sp.cb.cs)
                    if(vif_sp.cb.we==1) begin
                        `ifdef TRACE_ALL
                        $fdisplay(fd, "[WR]addr:0x%0h, data:0x%0h", vif_sp.cb.addr, vif_sp.cb.din);
                        `endif
                        cnt_write++;
                    end else begin
                        `ifdef TRACE_ALL
                        $fdisplay(fd, "[RD]addr:0x%0h, data:0x%0h", vif_sp.cb.addr, vif_sp.cb.dout);
                        `endif
                        cnt_read++;
                    end
                end
                forever begin: clear_sp
                    @(vif_sp.layer_done)
                    cnt_write = 0;
                    cnt_read = 0;
                    $fdisplay(fd, "layer%0d, W:%0d bytes, R:%0d bytes", num_layer, cnt_write*(DATA_WIDTH/8), cnt_read*(DATA_WIDTH/8));
                    num_layer++;
                end
            join

            $fclose(fd);
        end else if(vif_tp!=null) begin
            fd = $fopen({"./report/",name,".txt"}, "w");
            /* $display("%s, %d", name, fd); */
            if(!fd) $fatal("file open error");

            fork
                forever begin: porta
                    @(posedge vif_tp.cb.ena, vif_tp.cb.addra)
                    if(vif_tp.cb.wea==1) begin
                        `ifdef TRACE_ALL
                        $fdisplay(fd, "[WR]addr:0x%0h, data:0x%0h", vif_tp.cb.addra, vif_tp.cb.din);
                        `endif
                        cnt_write++;
                    end else begin
                        temp_read_addr = vif_tp.cb.addra;
                        @vif_tp.cb; // 1cycle consume to read data
                        `ifdef TRACE_ALL
                        $fdisplay(fd, "[RD]addr:0x%0h, data:0x%0h", temp_read_addr, vif_tp.cb.dout);
                        `endif
                        cnt_read++;
                    end
                end
                forever begin: portb
                    @(posedge vif_tp.cb.enb, vif_tp.cb.addrb)
                    if(vif_tp.cb.web==1) begin
                        `ifdef TRACE_ALL
                        $fdisplay(fd, "[WR]addr:0x%0h, data:0x%0h", vif_tp.cb.addrb, vif_tp.cb.din);
                        `endif
                        cnt_write++;
                    end else begin
                        temp_read_addr = vif_tp.cb.addrb;
                        @vif_tp.cb; // 1cycle consume to read data
                        `ifdef TRACE_ALL
                        $fdisplay(fd, "[RD]addr:0x%0h, data:0x%0h", temp_read_addr, vif_tp.cb.dout);
                        `endif
                        cnt_read++;
                    end
                end
                forever begin: clear_tp
                    @(posedge vif_tp.layer_done)
                    $fdisplay(fd, "layer%0d, W:%0d bytes, R:%0d bytes", num_layer, cnt_write*(DATA_WIDTH/8), cnt_read*(DATA_WIDTH/8));
                    cnt_write = 0;
                    cnt_read = 0;
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

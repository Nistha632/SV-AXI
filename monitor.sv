
class axi_monitor;
  
  axi_transaction_write tr_w;
  axi_transaction_read tr_r;
  event e_w,e_r;
  
  mailbox mon2scb_w;
  mailbox mon2scb_r;
  
  virtual axi_interface.monitor_mp vif;
  
  function new(mailbox mon2scb_w, mailbox mon2scb_r, virtual axi_interface vif,event e_w,event e_r );
    this.mon2scb_w = mon2scb_w;
    this.mon2scb_r = mon2scb_r;
    this.vif = vif;
    this.e_w = e_w;
    this.e_r = e_r;
  endfunction

  task run();
    forever begin
      tr_w = new();
      tr_r = new();
      @(vif.AXI_monitor_cb);
      
      if(vif.AXI_monitor_cb.WVALID) 
        begin
          tr_w.AWADDR = vif.AXI_monitor_cb.AWADDR;
          tr_w.AWLEN = vif.AXI_monitor_cb.AWLEN;
          tr_w.AWSIZE = vif.AXI_monitor_cb.AWSIZE;
          tr_w.AWBURST = vif.AXI_monitor_cb.AWBURST;
          tr_w.AWVALID = vif.AXI_monitor_cb.AWVALID;
          tr_w.AWREADY = vif.AXI_monitor_cb.AWREADY;
          tr_w.WDATA = vif.AXI_monitor_cb.WDATA;
          tr_w.WLAST = vif.AXI_monitor_cb.WLAST;
          tr_w.WVALID = vif.AXI_monitor_cb.WVALID;
          tr_w.WREADY = vif.AXI_monitor_cb.WREADY;
          if(axi_config::verbosity=="HIGH")  
            begin
              $display("====================================================");
              $display("----------->mon: mailbox: mon2scb_write<------------");
              $display("time=%0t %0p\n",$time,tr_w);
            end
           
          mon2scb_w.put(tr_w);
          @e_w;
        end
      
      if(vif.AXI_monitor_cb.RREADY) 
        begin
          tr_r.ARADDR = vif.AXI_monitor_cb.ARADDR;
          tr_r.ARLEN = vif.AXI_monitor_cb.ARLEN;
          tr_r.ARSIZE = vif.AXI_monitor_cb.ARSIZE;
          tr_r.ARBURST = vif.AXI_monitor_cb.ARBURST;
          tr_r.ARVALID = vif.AXI_monitor_cb.ARVALID;
          tr_r.RREADY = vif.AXI_monitor_cb.RREADY;
          tr_r.ARREADY = vif.AXI_monitor_cb.ARREADY;
          tr_r.RLAST = vif.AXI_monitor_cb.RLAST;
          tr_r.RVALID = vif.AXI_monitor_cb.RVALID;
          tr_r.RDATA = vif.AXI_monitor_cb.RDATA;
          if(axi_config::verbosity=="HIGH")  
            begin
              $display("====================================================");
              $display("----------->mon: mailbox: mon2scb_read<-------------");
              $display("time=%0t %0p",$time,tr_r);
            end
          mon2scb_r.put(tr_r);
          @e_r;
        end
      
    end
  endtask
  
endclass

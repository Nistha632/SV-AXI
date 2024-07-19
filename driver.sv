class axi_driver;
  axi_transaction_write tr_w;
  axi_transaction_read tr_r;
  bit [31 :0] mem [int];
  event e_w,e_r;
  parameter bit [1:0] FIXED=0;
  parameter bit [1:0] INCREMENT=1;
  parameter bit [1:0] WRAP=2;
  
  mailbox gen2drv_w;
  mailbox gen2drv_r;
  
  virtual axi_interface.driver_mp vif;
  
  function new(mailbox gen2drv_w, mailbox gen2drv_r, virtual axi_interface vif,event e_w,event e_r);
    this.gen2drv_w = gen2drv_w;
    this.gen2drv_r = gen2drv_r;
    this.vif = vif;
    this.e_w = e_w;
    this.e_r = e_r;
  endfunction
  
  task run();
    forever 
      begin
      fork
        begin:write
          tr_w=new();
          gen2drv_w.get(tr_w);
          
           @(vif.AXI_bfm_cb);
           ->e_w;
          
          //pin to obj //input
          tr_w.AWADDR = vif.AXI_bfm_cb.AWADDR;
          tr_w.AWLEN = vif.AXI_bfm_cb.AWLEN;
          tr_w.AWSIZE = vif.AXI_bfm_cb.AWSIZE;
          tr_w.AWBURST = vif.AXI_bfm_cb.AWBURST;
          tr_w.AWVALID = vif.AXI_bfm_cb.AWVALID;
          //tr_w.WDATA = vif.AXI_bfm_cb.WDATA;
          tr_w.WLAST = vif.AXI_bfm_cb.WLAST;
          tr_w.WVALID = vif.AXI_bfm_cb.WVALID;
          //obj to pin //output
          vif.AXI_bfm_cb.AWREADY <= tr_w.AWREADY;
          vif.AXI_bfm_cb.WREADY <= tr_w.WREADY;
          if(axi_config::verbosity=="HIGH")  
            begin
              $display("====================================================");
              $display("----------------->drv: vif_write<-------------------");
              $display("time=%0t %0p",$time,vif);
            end
          
          if (vif.AXI_bfm_cb.WVALID && tr_w.AWREADY) 
           begin
             $display("====================================================");
             $display("enter in WRITE mode");
            if(vif.AXI_bfm_cb.AWBURST==FIXED)
              begin
                fixed_write();
              end

            else if(vif.AXI_bfm_cb.AWBURST==INCREMENT)
              begin
                increment_write();
              end
            else
              begin
                if(axi_config::verbosity=="HIGH")  
                    begin
                        $display("no write operation");
                      $display("====================================================");
                    end
              end
             
           end
        end
        
        begin:read
          tr_r=new();
          gen2drv_r.get(tr_r);
          
          //pin to obj //input
          tr_r.ARADDR = vif.AXI_bfm_cb.ARADDR;
          tr_r.ARLEN = vif.AXI_bfm_cb.ARLEN;
          tr_r.ARSIZE = vif.AXI_bfm_cb.ARSIZE;
          tr_r.ARBURST = vif.AXI_bfm_cb.ARBURST;
          tr_r.ARVALID = vif.AXI_bfm_cb.ARVALID;
          tr_r.RREADY = vif.AXI_bfm_cb.RREADY;
          
          //obj to pin //output
          vif.AXI_bfm_cb.ARREADY <= tr_r.ARREADY;
          vif.AXI_bfm_cb.RLAST <= tr_r.RLAST;
          vif.AXI_bfm_cb.RVALID <= tr_r.RVALID;
          if(axi_config::verbosity=="HIGH")  
            begin
              $display("====================================================");
              $display("------------------>drv: vif_read<-------------------");
              $display("time=%0t %0p",$time,vif);
            end
          
          if (vif.AXI_bfm_cb.RREADY && tr_r.ARREADY) 
           begin
             $display("====================================================");
             $display("enter in READ mode");
                if(vif.AXI_bfm_cb.ARBURST==FIXED)
                  begin
                    fixed_read();
                  end

                else if(vif.AXI_bfm_cb.ARBURST==INCREMENT)
                  begin
                    increment_read();
                  end
                else
                  begin
                    if(axi_config::verbosity=="HIGH")  
                        begin
                            $display("no read operation");
                          $display("====================================================");
                        end
                  end

              end
          @(vif.AXI_bfm_cb);
                 ->e_r;
        end
      join_any
      
        
      end
        
  endtask

  
  task fixed_write();
    if(axi_config::verbosity=="HIGH")  
      begin
        $display("====================================================");
        $display("New address fetched for write [Fixed] operation");
        $display("====================================================");
      end
    repeat(vif.AXI_bfm_cb.AWLEN+1)    
       begin
         mem[tr_w.AWADDR] = vif.AXI_bfm_cb.WDATA;
         if(axi_config::verbosity=="HIGH")  
           begin
             $display("====================================================");
             $display("------------------>DRV: Write data FIX<-------------");
             $display("\tTime: %0t, Writing to mem[%0h] = %0d\n", $time, tr_w.AWADDR, mem[tr_w.AWADDR]); 
           end
         @(vif.AXI_bfm_cb);
       end
  endtask
    
   task increment_write();
     if(axi_config::verbosity=="HIGH")  
       begin
         $display("====================================================");
         $display("New address fetched for write [Incremental] operation");
         $display("====================================================");
       end
     for (int i = 0; i < (vif.AXI_bfm_cb.AWLEN+1) ; i++)
       begin
         mem[tr_w.AWADDR] = vif.AXI_bfm_cb.WDATA;
         if(axi_config::verbosity=="HIGH")  
           begin
             $display("====================================================");
             $display("----------------->DRV: Write data INC<--------------");
             $display("\tTime: %0t, i=%0d Writing to mem[%0h] = %0d\n", $time, i,tr_w.AWADDR, mem[tr_w.AWADDR]);
           end
          @(vif.AXI_bfm_cb);
         
         tr_w.AWADDR = tr_w.AWADDR + (2**tr_w.AWSIZE);
         
       end
  endtask

  task fixed_read();
    if(axi_config::verbosity=="HIGH")  
      begin
        $display("====================================================");
        $display("New address fetched for Read [Fixed] Operation");
        $display("====================================================");
      end
    
    repeat(vif.AXI_bfm_cb.ARLEN+1)    
       begin
         tr_r.RDATA = mem[tr_r.ARADDR];
         vif.AXI_bfm_cb.RDATA <= tr_r.RDATA;
         if(axi_config::verbosity=="HIGH")  
            begin
             $display("====================================================");
             $display("----------------->DRV: READ data FIX<---------------");
             $display("\tTime: %0t, reading to mem[%0h] = %0d\n", $time,tr_r.ARADDR, mem[tr_r.ARADDR]);
            end
            @(vif.AXI_bfm_cb);
          end

  endtask
    
  
   task increment_read();
     if(axi_config::verbosity=="HIGH")  
       begin
         $display("====================================================");
         $display("New address fetched for Read [Incremental] operation");
         $display("====================================================");
       end
     for (int i = 0; i < (vif.AXI_bfm_cb.ARLEN+1); i++)
       begin
//       mem[tr_r.ARADDR]=i+100;
         tr_r.RDATA = mem[tr_r.ARADDR];
         vif.AXI_bfm_cb.RDATA <= tr_r.RDATA;
         if(axi_config::verbosity=="HIGH")  
           begin
             $display("====================================================");
             $display("------------------>DRV: READ data INC<--------------");
             $display("\tTime: %0t, reading to mem[%0h] = %0d\n", $time,tr_r.ARADDR, mem[tr_r.ARADDR]);
           end
         tr_r.ARADDR = tr_r.ARADDR + (2**tr_r.ARSIZE);
         @(vif.AXI_bfm_cb);
       end
  endtask
  
endclass  


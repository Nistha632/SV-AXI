class axi_scoreboard;
  bit [31 :0] mem[int];
  
  axi_transaction_write tr_w;
  axi_transaction_read tr_r;
  event e_w,e_r;
  
  mailbox mon2scb_w;
  mailbox mon2scb_r;
  
  function new(mailbox mon2scb_w, mailbox mon2scb_r,event e_w,event e_r);
    this.mon2scb_w = mon2scb_w;
    this.mon2scb_r = mon2scb_r;
    this.e_w = e_w;
    this.e_r = e_r;
  endfunction
  
  task run();
    
    forever
      begin
        
        fork
        begin:write
          mon2scb_w.get(tr_w);
          mem[tr_w.AWADDR]=tr_w.WDATA;
          if(axi_config::verbosity=="HIGH")  
            begin
              $display("====================================================");
              $display("time=%0t mem[%0d]=%0d",$time,tr_w.AWADDR, mem[tr_w.AWADDR]);
              $display("====================================================");
              $display("----------->scb: mailbox: mon2scb_write<------------");
              $display("time=%0t %0p\n",$time,tr_w);
            end
            ->e_w;
        end
          
          begin : read
            mon2scb_r.get(tr_r);
            if(tr_r.RDATA==mem[tr_r.ARADDR-4])
              begin
                if(axi_config::verbosity=="LOW" || axi_config::verbosity=="HIGH")   
                begin
                        $display("====================================================");
                        $display("time=%0t actual_data=%0d expected_data=%0d\n",$time,tr_r.RDATA, mem[tr_r.ARADDR-4]);
                        $display(">>>>>>>>>>>>>>>>>>>> Test Passed <<<<<<<<<<<<<<<<<<<");
                end
              end
            else
               begin
                 if(axi_config::verbosity=="LOW" || axi_config::verbosity=="HIGH") 
                  begin
                   $display("====================================================");
                   $display("time=%0t actual_data=%0d expected_data=%0d",$time,tr_r.RDATA, mem[tr_r.ARADDR-4]);
                   $display(">>>>>>>>>>>>>>>>>>>> Test Failed <<<<<<<<<<<<<<<<<<<");
                  end
              end
            if(axi_config::verbosity=="HIGH")  
                  begin
                    $display("====================================================");
                    $display("----------->scb: mailbox: mon2scb_read<------------");
                    $display("time=%0t %0p\n",$time,tr_r);
                  end
                    ->e_r;
                 
          end
        
        join
        
      end
    
  endtask
endclass


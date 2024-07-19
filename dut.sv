

module axi_design #( parameter DATA_WIDTH = 32, ADRESS_WIDTH = 32 )(
    //global signals
    input ACLK,
    input ARESETn,
    //master write address signals
    output reg [ ADRESS_WIDTH - 1 : 0 ] AWADDR,
    output reg [3:0] AWLEN,
    output reg [2:0] AWSIZE,
    output reg [1:0] AWBURST,
    output reg AWVALID,
    input AWREADY,
    //master write data signals
    output reg [ DATA_WIDTH - 1 : 0 ] WDATA,
    output reg WLAST,
    output reg WVALID,
    input WREADY,
    //master read address signals
    output reg [ ADRESS_WIDTH - 1 : 0 ] ARADDR,
    output reg [3:0] ARLEN,
    output reg [2:0] ARSIZE,
    output reg [1:0] ARBURST,
    output reg ARVALID,
    input ARREADY,
    //master read data signals
    input [ DATA_WIDTH - 1 : 0 ] RDATA,
    input RLAST,
    input RVALID,
    output reg RREADY
);
 
bit [DATA_WIDTH - 1 :0] mem[int];
int f_data;
 
  always@(posedge ACLK , negedge ARESETn )
begin
     if(!ARESETn)
        begin
            AWVALID = 0;
            WVALID = 0;
            ARVALID = 0;
            RREADY = 0;
          $display("@%0t reset is asserted",$time);
        end
     else
         begin
            AWVALID = 1;
            WVALID = 1;
            ARVALID = 1;
            RREADY = 1;
            fork
              awcheck();
              archeck();
               begin
                if(AWVALID && AWREADY)
                 begin
                   wcheck();
                 end
                end
                begin
                  if(ARVALID && ARREADY)
                 begin
                    rcheck();
                 end
                end
            join
            $display();
         end
end

/////////////////////////////////////////////////////////////////
//Method Name: awcheck
//Parameters Passed: None
//Returned Parameter: None
//Description: Check handshaking for AWADDR
/////////////////////////////////////////////////////////////////
 
task awcheck();
    // Check if AWVALID is asserted and AWREADY is not asserted
    if (AWVALID && !AWREADY) begin
        fork
            begin
                // Wait for AWREADY to be asserted or timeout
                repeat (16) begin
                    @(posedge ACLK);
                    if (AWREADY == 1 && AWVALID == 1) begin
                        break;
                    end
                    else if (AWVALID == 1 && AWREADY == 0) begin
                    end
                    else begin
                        $display("break");
                        break;
                    end
                end
            end
            begin
                // Timeout message
                repeat (16) @(posedge ACLK);
                $error("time out occur");
            end
        join_any
        disable fork;
    end
    else if (AWVALID && AWREADY) begin
       
//       randomize(AWADDR) with {AWADDR > 0; AWADDR < 100;};
      randomize(AWADDR) with {AWADDR == 100;};
        AWLEN = 3;
        AWSIZE = 2;
        AWBURST =1;//2'b01

    end
endtask: awcheck

/////////////////////////////////////////////////////////////////
//Method Name: wcheck
//Parameters Passed: None
//Returned Parameter: None
//Description: check handshaking for WDATA
/////////////////////////////////////////////////////////////////
 
task wcheck();
    // Check if AWVALID is asserted and AWREADY is not asserted
    if (WVALID && !WREADY) begin
        fork
            begin
                // Wait for AWREADY to be asserted or timeout
                repeat (16) begin
                    @(posedge ACLK);
                    if (WREADY == 1 && WVALID == 1) begin
                        break;
                    end
                    else if (WVALID == 1 && WREADY == 0) begin
                    end
                    else begin
                        $display("break");
                        break;
                    end
                end
            end
            begin
                // Timeout message
                repeat (16) @(posedge ACLK);
                $error("time out occur");
            end
        join_any
        disable fork;
    end
    else if (WVALID && WREADY) begin
      
      for(int j=0 ; j < AWLEN+1 ; j++)
        begin   
         WDATA = j+1;
          
          if(j==AWLEN)
            begin
                WLAST=1;
            end
            else
            begin
                WLAST=0;
            end
          @(posedge ACLK);
          if(AWBURST==2'b01 )
                      begin
                          AWADDR+=4;
                      end
        end
    end
endtask: wcheck

/////////////////////////////////////////////////////////////////
//Method Name: archeck
//Parameters Passed: None
//Returned Parameter:None
//Description: check handshacking for ARADDR
/////////////////////////////////////////////////////////////////

task archeck();
    // Check if AWVALID is asserted and AWREADY is not asserted
   if (ARVALID && !ARREADY) begin
        fork
            begin
                // Wait for AWREADY to be asserted or timeout
                repeat (16) begin
                    @(posedge ACLK);
                  if (ARREADY == 1 && ARVALID == 1) begin
                        break;
                    end
                  else if (ARVALID == 1 && ARREADY == 0) begin
                    end
                    else begin
                        $display("break");
                        break;
                    end
                end
            end
            begin
                // Timeout message
                repeat (16) @(posedge ACLK);
                $error("time out occur");
            end
        join_any
        disable fork;
    end
    else if (ARVALID && ARREADY) begin
//       randomize(ARADDR) with {ARADDR > 0; ARADDR < 100;};
      randomize(ARADDR) with {ARADDR == 100;};
        ARLEN = 3;
        ARSIZE = 2;
        ARBURST = 1;//2'b01
    
    end
endtask: archeck

/////////////////////////////////////////////////////////////////
//Method Name: rcheck
//Parameters Passed: None
//Returned Parameter: None
//Description: chekc handshaking for RDATA
/////////////////////////////////////////////////////////////////
task rcheck();
    // Check if AWVALID is asserted and AWREADY is not asserted
   if (!RVALID && RREADY) begin
        fork
            begin
                // Wait for AWREADY to be asserted or timeout
                repeat (16) begin
                    @(posedge ACLK);
                  if (RREADY == 1 && RVALID == 1) begin
                        break;
                    end
                  else if (RVALID == 0 && RREADY == 1) begin
                    end
                    else begin
                        $display("break");
                        break;
                    end
                end
            end
            begin
                // Timeout message
                repeat (16) @(posedge ACLK);
                $error("time out occur");
            end
        join_any
        disable fork;
    end
    else if (RVALID && RREADY) begin
      
      for(int j=0 ; j < ARLEN+1 ; j++)
            begin
              @(posedge ACLK);
                    mem[ARADDR]=RDATA;
              if(axi_config::verbosity=="HIGH")  
              begin
                $display("====================================================");
                $display("-------------------->DUT: READ data<----------------");
                $display("@%0t data=%0d addr=%0h",$time,mem[ARADDR],ARADDR);
              end

                    if(ARBURST==2'b01 )
                      begin
                          ARADDR+=4;
                      end
            
            end
        
    end
endtask: rcheck
 
endmodule




class axi_transaction_write #(parameter ADD_SIZE = 32, DATA_SIZE = 32, LEN_SIZE = 4, S_SIZE = 3, BURST_SIZE = 2);
  bit [ ADD_SIZE - 1 : 0 ] AWADDR;
  bit [ LEN_SIZE - 1 : 0 ] AWLEN;
  bit [ S_SIZE - 1 : 0 ] AWSIZE;
  bit [ BURST_SIZE - 1 : 0 ] AWBURST;
  bit AWVALID;
  rand bit AWREADY;
  bit [ DATA_SIZE - 1 : 0 ] WDATA;
  bit WLAST;
  bit WVALID;
  rand bit WREADY;
  
endclass

class axi_transaction_read #(parameter ADD_SIZE = 32, DATA_SIZE = 32, LEN_SIZE = 4, S_SIZE = 3, BURST_SIZE = 2);
  bit [ ADD_SIZE - 1 : 0 ] ARADDR;
  bit [ LEN_SIZE - 1 : 0 ] ARLEN;
  bit [ S_SIZE - 1 : 0 ] ARSIZE;
  bit [ BURST_SIZE - 1 : 0 ] ARBURST;
  bit ARVALID;
  rand bit ARREADY;
  bit [ DATA_SIZE - 1 : 0 ] RDATA;
  bit RLAST;
  rand bit RVALID;
  bit RREADY;
  
endclass



interface axi_interface #(parameter ADD_SIZE = 32, DATA_SIZE = 32, LEN_SIZE = 4, S_SIZE = 3, BURST_SIZE = 2)(input bit ACLK ,input bit  ARESETn);
  //write transation
  logic [ ADD_SIZE - 1 : 0 ] AWADDR;
  logic [ LEN_SIZE -1 : 0 ] AWLEN;
  logic [ S_SIZE-1 : 0 ] AWSIZE;
  logic [ BURST_SIZE -1 : 0] AWBURST;
  logic AWVALID;
  logic AWREADY;
  logic [ DATA_SIZE - 1 : 0 ] WDATA;
  logic WLAST;
  logic WVALID;
  logic WREADY;
  //read transaction
  logic [ ADD_SIZE -1 : 0 ] ARADDR;
  logic [ LEN_SIZE - 1 : 0 ] ARLEN;
  logic [ S_SIZE-1 : 0 ] ARSIZE;
  logic [ BURST_SIZE -1 : 0] ARBURST;
  logic ARVALID;
  logic ARREADY;
  logic [ DATA_SIZE - 1 : 0 ] RDATA;
  logic RLAST;
  logic RVALID;
  logic RREADY;

  clocking AXI_bfm_cb@(posedge ACLK);
    default input #1step output #0;
    // Global Signals   
    input ACLK;
    input ARESETn;
    // Write Signals
    input AWADDR;
    input AWLEN;
    input AWSIZE;
    input AWBURST;
    input AWVALID;
    output AWREADY;
    input WDATA;
    input WLAST;
    input WVALID;
    output WREADY;
    // Read Signals
    input ARADDR;
    input ARLEN;
    input ARSIZE;
    input ARBURST;
    input ARVALID;
    output ARREADY;
    output RDATA;
    output RLAST;
    output RVALID;
    input RREADY;
  endclocking
  clocking AXI_monitor_cb@(posedge ACLK);
    default input #1;
    // Global Signals   
    input ACLK;
    input ARESETn;
    // Write Signals
    input AWADDR;
    input AWLEN;
    input AWSIZE;
    input AWBURST;
    input AWVALID;
    input AWREADY;
    input WDATA;
    input WLAST;
    input WVALID;
    input WREADY;
    // Read Signals
    input ARADDR;
    input ARLEN;
    input ARSIZE;
    input ARBURST;
    input ARVALID;
    input ARREADY;
    input RDATA;
    input RLAST;
    input RVALID;
    input RREADY;
  endclocking
  
  modport driver_mp(clocking AXI_bfm_cb);
  modport monitor_mp(clocking AXI_monitor_cb);
endinterface





class axi_config;
  static string verbosity;
   typedef enum {ACTIVE,PASSIVE} agent_e;
  
  virtual axi_interface vif;
  agent_e master_agent_active_passive_switch=ACTIVE;

  static task run();
    
    
    if($value$plusargs("verbosity=%s",verbosity))    
        begin
          $display("%0s verbosity is selected",verbosity);
          $display("----------------------------------------------------");
        end
    else
      begin
        $error("verbosity is not selected");
        $display("----------------------------------------------------");
      end
    
  endtask
  
  
endclass



class axi_generator;
  axi_transaction_write tr_w;
  axi_transaction_read tr_r;
  event e_w,e_r;
  mailbox gen2drv_w;
  mailbox gen2drv_r;
  
  
  function new(mailbox gen2drv_w, mailbox gen2drv_r, event e_w,event e_r);
    this.gen2drv_w = gen2drv_w;
    this.gen2drv_r = gen2drv_r;
    this.e_w = e_w;
    this.e_r = e_r;
  endfunction
  
   virtual task run();
     //needed for instationation child class
   endtask
   
      task put_write();
        if(axi_config::verbosity=="HIGH")  
            begin
              $display("====================================================");
              $display("----------->gen: mailbox: gen2drv_write<------------");
              $display("time=%0t %0p",$time,tr_w);
            end
            gen2drv_w.put(tr_w);
            @e_w;
      endtask
      
          
      task put_read();
        if(axi_config::verbosity=="HIGH")  
            begin
              $display("====================================================");
              $display("----------->gen: mailbox: gen2drv_read<------------");
              $display("time=%0t %0p",$time,tr_r);
            end
            gen2drv_r.put(tr_r);
            @e_r;
      endtask

  
endclass

class axi_only_write extends axi_generator;
  
  
  function new(mailbox gen2drv_w, mailbox gen2drv_r, event e_w,event e_r);
    super.new(gen2drv_w,gen2drv_r, e_w,e_r);
    this.gen2drv_w = gen2drv_w;
    this.gen2drv_r = gen2drv_r;
    this.e_w = e_w;
    this.e_r = e_r;
  endfunction
  
  
  task run();
    repeat(20)
      begin
        tr_w=new();
        tr_r=new();
        if(! tr_w.randomize() with {tr_w.AWREADY==1 ; tr_w.WREADY==1 ;})
          $fatal("write randomization fail..");
        
        else
          put_write();
      end
  endtask
endclass


class axi_only_read extends axi_generator;
  
  
  function new(mailbox gen2drv_w, mailbox gen2drv_r, event e_w,event e_r);
    super.new(gen2drv_w,gen2drv_r, e_w,e_r);
    this.gen2drv_w = gen2drv_w;
    this.gen2drv_r = gen2drv_r;
    this.e_w = e_w;
    this.e_r = e_r;
  endfunction

 task run();
    repeat(20)
      begin
        tr_w=new();
        tr_r=new();
        if(! tr_r.randomize() with {tr_r.ARREADY==1 ; tr_r.RVALID==1;})
          $fatal("read randomization fail..");
       
        else
          put_read();
      end
  endtask
endclass


class axi_parallel_read_write extends axi_generator;
  
  
  function new(mailbox gen2drv_w, mailbox gen2drv_r, event e_w,event e_r);
    super.new(gen2drv_w,gen2drv_r, e_w,e_r);
    this.gen2drv_w = gen2drv_w;
    this.gen2drv_r = gen2drv_r;
    this.e_w = e_w;
    this.e_r = e_r;
  endfunction
  
  task run();
    repeat(20)
      begin
        tr_w=new();
        tr_r=new();
        
        fork
          begin
            if(! tr_r.randomize() with {tr_r.ARREADY==1 ; tr_r.RVALID==1;})
              $fatal("parallel read write randomization fail..");

            else
              put_read();
            
          end
          
          begin
            if(! tr_w.randomize() with {tr_w.AWREADY==1 ; tr_w.WREADY==1 ;})
              $fatal("parallel read write randomization fail..");

            else
              put_write();
            
          end
          join
      end
  endtask
endclass


class axi_sequential_read_write extends axi_generator;

  function new(mailbox gen2drv_w, mailbox gen2drv_r, event e_w,event e_r);
    super.new(gen2drv_w,gen2drv_r, e_w,e_r);
    this.gen2drv_w = gen2drv_w;
    this.gen2drv_r = gen2drv_r;
    this.e_w = e_w;
    this.e_r = e_r;
  endfunction
  
   task run();
   
        tr_w=new();
        tr_r=new();
   
      repeat(3)
      begin
        if(! tr_r.randomize() with {tr_r.ARREADY==1 ; tr_r.RVALID==1; })
          $fatal("read randomization fail..");
       
        else
          put_read();
      end
   
    repeat(6)
      begin
        if(! tr_w.randomize() with {tr_w.AWREADY==1 ; tr_w.WREADY==1;})
          $fatal("write randomization fail..");
       
        else
          put_write();
      end
   
        if(! tr_r.randomize() with {tr_r.ARREADY==1 ; tr_r.RVALID==1; })
          $fatal("read randomization fail..");
       
        else
          put_read();
     
   
   
        if(! tr_w.randomize() with {tr_w.AWREADY==1 ; tr_w.WREADY==1 ;})
          $fatal("write randomization fail..");
       
        else
          put_write();
     
  endtask
endclass




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



class axi_agent;
  
  axi_config env_cfg;
  axi_generator gen;
  axi_driver drv;
  axi_monitor mon;
  
  virtual axi_interface vif;
  
  mailbox gen2drv_w=new();
  mailbox gen2drv_r=new();
  mailbox mon2sco_w;
  mailbox mon2sco_r;
  event e_w,e_r;
  event e_done_w, e_done_r;
  
  function new(mailbox mon2sco_w,
                       mon2sco_r,
               event e_done_w,
                     e_done_r,
              virtual axi_interface vif,
              axi_config env_cfg);
    
    this.gen2drv_w = gen2drv_w;
    this.gen2drv_r = gen2drv_r;
    this.mon2sco_w = mon2sco_w;
    this.mon2sco_r = mon2sco_r;
    this.e_done_w = e_done_w;
    this.e_done_r = e_done_r;
    this.vif = vif;
    this.env_cfg = env_cfg;
    if(this.env_cfg.master_agent_active_passive_switch == axi_config :: ACTIVE)
      begin
        gen = new(gen2drv_w, gen2drv_r, e_w, e_r);
        drv = new(gen2drv_w, gen2drv_r, vif, e_w, e_r);
      end
    mon = new(mon2sco_w, mon2sco_r, vif, e_done_w, e_done_r);
  endfunction
  
  
  task run();
    
    fork
      gen.run();
      drv.run();
      mon.run();
    join
  endtask
  
endclass







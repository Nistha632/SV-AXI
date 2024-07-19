
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


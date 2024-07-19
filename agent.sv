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


class axi_environment;
  axi_agent agent;
  axi_scoreboard sco;
  axi_config configs=new();
  
  virtual axi_interface vif;
  mailbox mon2sco_w=new();
  mailbox mon2sco_r=new();
  event e_done_w, e_done_r;
  function new(virtual axi_interface vif);
    this.vif = vif;
    
    agent = new(mon2sco_w, mon2sco_r, e_done_w, e_done_r, vif, configs);
    sco = new(mon2sco_w, mon2sco_r, e_done_w, e_done_r);
  endfunction
  
  task run();
    fork
      axi_config::run();
      agent.run();
      sco.run();
    join
  endtask : run
  
endclass

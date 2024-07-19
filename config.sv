
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


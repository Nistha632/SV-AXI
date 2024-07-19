
`include "config.sv";
`include "dut.sv";
`include "transaction.sv";
`include "interface.sv";
`include "generator.sv";
`include "driver.sv";
`include "monitor.sv";
`include "scoreboard.sv";
`include "agent.sv";
`include "env.sv";
`include "test.sv";

 
module TOP #(parameter delay = 5, parameter rst_delay = 105);
  logic ACLK , ARESETn;
  string testname1;
  
  axi_test test;
  axi_interface#() pif(ACLK, ARESETn);
  axi_design#() dut(pif.ACLK,pif.ARESETn,pif.AWADDR,pif.AWLEN,pif.AWSIZE,pif.AWBURST,pif.AWVALID,pif.AWREADY,pif.WDATA,pif.WLAST,pif.WVALID,pif.WREADY,pif.ARADDR,pif.ARLEN,pif.ARSIZE,pif.ARBURST,pif.ARVALID,pif.ARREADY,pif.RDATA,pif.RLAST,pif.RVALID,pif.RREADY);
  //Clock Generation
  initial
    begin
       test = new(pif);
      ACLK = 0;
      ARESETn=1;
      if($value$plusargs("testname1=%s",testname1)) 
        begin
          $display("%0s testcase is selected for reset after %0d delay",testname1,rst_delay);
          $display("----------------------------------------------------");
          case(testname1)
           "ei_axi_reset" :
             begin
             #rst_delay;
            ARESETn=0;
             end
          endcase
        end
    end
  
  
  initial
    begin
      forever #(delay) ACLK = ~ ACLK;
    end
   // run method
  always@(posedge ACLK)
    begin
      test.run();
    end
  initial
    begin
      $dumpfile("dump.vcd");
      $dumpvars;
    end
  initial 
    begin
      #200 $finish;
    end
endmodule





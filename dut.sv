

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










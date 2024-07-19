
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


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

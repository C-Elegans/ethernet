module top(/*AUTOARG*/
   // Outputs
   rgmii_tx_clk, rgmii_tx_ctrl, rgmii_txd, rgmii_rstn, sec_tx_clk,
   sec_tx_ctrl, sec_tx_dat,
   // Inputs
   clk_100, rstn
   );

    output rgmii_tx_clk;
    output rgmii_tx_ctrl;
    output [3:0] rgmii_txd;
    output 	 rgmii_rstn;

    output 	 sec_tx_clk;
    output 	 sec_tx_ctrl;
    output 	 sec_tx_dat;

    input  clk_100;
    input  rstn;
    wire   clk;
    wire   clko;

    wire   tx_clk;
    wire   tx_ctrl;
    wire [3:0] txd;

    wire       pll_lock = 1;
    assign rgmii_tx_clk = tx_clk;
    assign rgmii_txd = txd;

    assign sec_tx_clk = tx_clk;
    wire		mac_rst;		// From reset of reset.v
    wire		o_wb_ack;		// From mac of mac.v
    wire [1:0]		o_wb_addr;		// From wb_master of master.v
    wire		o_wb_cyc;		// From wb_master of master.v
    wire [7:0]		o_wb_data;		// From mac of mac.v, ...
    wire		o_wb_stall;		// From mac of mac.v
    wire		o_wb_stb;		// From wb_master of master.v
    wire		o_wb_we;		// From wb_master of master.v

   wire 		rgmii_rx_clk;
   wire 		rgmii_rx_ctrl;
   wire [3:0] 		rgmii_rxd;

    reset reset(/*AUTOINST*/
		// Outputs
		.rgmii_rstn		(rgmii_rstn),
		.mac_rst		(mac_rst),
		// Inputs
		.clk			(clk),
		.rstn			(rstn),
		.pll_lock		(pll_lock));

   mac mac(
	   // Outputs
	   .rgmii_tx_clk		(rgmii_tx_clk),
	   .rgmii_txd			(rgmii_txd[3:0]),
	   .rgmii_tx_ctrl		(rgmii_tx_ctrl),
	   .o_wb_ack			(o_wb_ack),
	   .o_wb_stall			(o_wb_stall),
	   .o_wb_data			(o_wb_data[7:0]),
	   // Inputs
	   .rgmii_rx_clk		(rgmii_rx_clk),
	   .rgmii_rxd			(rgmii_rxd[3:0]),
	   .rgmii_rx_ctrl		(rgmii_rx_ctrl),
	   .clk				(clk),
	   .rst				(mac_rst),
	   .i_wb_cyc			(o_wb_cyc),
	   .i_wb_stb			(o_wb_stb),
	   .i_wb_we			(o_wb_we),
	   .i_wb_addr			(o_wb_addr[1:0]),
	   .i_wb_data			(o_wb_data[7:0]));
   master wb_master(
		    // Outputs
		    .o_wb_cyc		(o_wb_cyc),
		    .o_wb_stb		(o_wb_stb),
		    .o_wb_we		(o_wb_we),
		    .o_wb_addr		(o_wb_addr[1:0]),
		    .o_wb_data		(o_wb_data[7:0]),
		    // Inputs
		    .clk		(clk),
		    .rst		(mac_rst),
		    .i_wb_ack		(o_wb_ack),
		    .i_wb_stall		(o_wb_stall),
		    .i_wb_data		(o_wb_data[7:0]));
`ifdef VERILATOR
   assign 		clk = clk_100;
   `else
    pll pll(
	    // Outputs
	    .clko			(clk),
	    // Inputs
	    .clki			(clk_100));
   `endif

	       
endmodule // top


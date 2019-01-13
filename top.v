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
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire		mac_rst;		// From reset of reset.v
    // End of automatics

    reset reset(/*AUTOINST*/
		// Outputs
		.rgmii_rstn		(rgmii_rstn),
		.mac_rst		(mac_rst),
		// Inputs
		.clk			(clk),
		.rstn			(rstn),
		.pll_lock		(pll_lock));
    gmii_to_rgmii eth(
		      // Outputs
		      .rgmii_tx_clk	(tx_clk),
		      .rgmii_tx_ctrl	(rgmii_tx_ctrl),
				 .sec_ctrl (sec_tx_ctrl),
				 .sec_q (sec_tx_dat),
		      .rgmii_txd	(txd[3:0]),
		      // Inputs
		      .rgmii_rx_clk	(rgmii_rx_clk),
		      .rgmii_rx_ctrl	(rgmii_rx_ctrl),
		      .rgmii_rxd	(rgmii_rxd[3:0]),
		      .clk		(clk),
		      .rst		(mac_rst));
    pll pll(
	    // Outputs
	    .clko			(clk),
	    // Inputs
	    .clki			(clk_100));

	       
endmodule // top


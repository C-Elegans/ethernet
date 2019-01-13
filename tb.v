module tb;

    /*AUTOREGINPUT*/
    // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
    reg			clk;			// To uut of gmii_to_rgmii.v
    reg			rgmii_rx_clk;		// To uut of gmii_to_rgmii.v
    reg			rgmii_rx_ctrl;		// To uut of gmii_to_rgmii.v
    reg [3:0]		rgmii_rxd;		// To uut of gmii_to_rgmii.v
    reg			rst;			// To uut of gmii_to_rgmii.v
    // End of automatics
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire		rgmii_tx_clk;		// From uut of gmii_to_rgmii.v
    wire		rgmii_tx_ctrl;		// From uut of gmii_to_rgmii.v
    wire [3:0]		rgmii_txd;		// From uut of gmii_to_rgmii.v
    // End of automatics

    gmii_to_rgmii uut(/*AUTOINST*/
		      // Outputs
		      .rgmii_tx_clk	(rgmii_tx_clk),
		      .rgmii_tx_ctrl	(rgmii_tx_ctrl),
		      .rgmii_txd	(rgmii_txd[3:0]),
		      // Inputs
		      .rgmii_rx_clk	(rgmii_rx_clk),
		      .rgmii_rx_ctrl	(rgmii_rx_ctrl),
		      .rgmii_rxd	(rgmii_rxd[3:0]),
		      .clk		(clk),
		      .rst		(rst));
    initial begin
	$dumpfile("dump.vcd");
	$dumpvars;
	clk = 0;
	rst = 1;
	#20 rst = 0;

	#5000 $finish;
    end
    always #5 clk <= ~clk;

    
	
	  

endmodule // tb

     

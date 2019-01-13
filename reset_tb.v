module reset_tb;
    /*AUTOWIRE*/
    // Beginning of automatic wires (for undeclared instantiated-module outputs)
    wire		mac_rst;		// From reset of reset.v
    wire		rgmii_rstn;		// From reset of reset.v
    // End of automatics
     /*AUTOREGINPUT*/
     // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
     reg		clk;			// To reset of reset.v
     reg		pll_lock;		// To reset of reset.v
     reg		rstn;			// To reset of reset.v
     // End of automatics
    reset reset(/*AUTOINST*/
		// Outputs
		.rgmii_rstn		(rgmii_rstn),
		.mac_rst		(mac_rst),
		// Inputs
		.clk			(clk),
		.rstn			(rstn),
		.pll_lock		(pll_lock));
    initial begin
	$dumpfile("dump.vcd");
	$dumpvars;
	clk = 0;
	pll_lock = 1;
	rstn = 0;
	#20 rstn = 1;
	#500 $finish;
    end
    always #5 clk <= ~clk;
endmodule // reset_tb

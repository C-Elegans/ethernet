module gmii_to_rgmii(/*AUTOARG*/
    // Outputs
    rgmii_tx_clk, rgmii_tx_ctrl, sec_ctrl, sec_q, rgmii_txd,
    // Inputs
    rgmii_rx_clk, rgmii_rx_ctrl, rgmii_rxd, clk, rst
    );
    input rgmii_rx_clk;
    input rgmii_rx_ctrl;
    input [3:0] rgmii_rxd;

    output reg	rgmii_tx_clk;
    output reg	rgmii_tx_ctrl;
    output reg	sec_ctrl;
    output reg	sec_q;
    output reg [3:0] rgmii_txd;

    input 	 clk;
    input 	 rst;

    reg 	 en;

    reg [7:0] 	 tx_data ;
    reg 	 tx_en ;
    reg 	 tx_er = 0;

    reg [3:0] 	 txd_next;
    reg 	 tx_ctrl_next;

    reg [0:0] 	 ctr;

    always @(*)
      rgmii_tx_clk = clk;

    genvar 	 i;
    generate
	for(i=0; i<4; i++) begin : txd 
	  ODDRX1F txd(
		      .D0(tx_data[i]),
		      .D1(tx_data[i+4]),
		      .RST(rst),
		      .SCLK(clk),
		      .Q(rgmii_txd[i]));
	end
    endgenerate
    ODDRX1F ctrl(
		 .D0(tx_en),
		 .D1(tx_en),
		 .RST(rst),
		 .SCLK(clk),
		 .Q(rgmii_tx_ctrl));
    ODDRX1F secctrl(
		 .D0(tx_en),
		 .D1(tx_en),
		 .RST(rst),
		 .SCLK(clk),
		 .Q(sec_ctrl));
    ODDRX1F secq(
		.D0(tx_data[0]),
		.D1(tx_data[4]),
		.RST(rst),
		.SCLK(clk),
		.Q(sec_q));
    
    

    reg [14:0] counter;
    reg [7:0] frame [0:127];
    initial $readmemh("frame.hex", frame);
    always @(posedge clk) begin
	if(rst == 1) begin
	    /*AUTORESET*/
	    // Beginning of autoreset for uninitialized flops
	    counter <= 11'h0;
	    tx_data <= 8'h0;
	    tx_en <= 1'h0;
	    // End of automatics
	end
	else begin
	    counter <= counter + 1;
	    tx_en <= counter > 0 && counter <= 72;
	    tx_data <= tx_en ? frame[counter[6:0]] : 0;

	end
    end
    
    
    


endmodule // gmii_to_rgmii


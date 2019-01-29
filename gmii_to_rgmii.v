module gmii_to_rgmii(/*AUTOARG*/
   // Outputs
   rgmii_tx_clk, rgmii_tx_ctrl, sec_ctrl, sec_q, rgmii_txd,
   gmii_rx_clk, gmii_rx_data, gmii_rx_en, gmii_rx_er,
   // Inputs
   rgmii_rx_clk, rgmii_rx_ctrl, rgmii_rxd, gmii_tx_clk, gmii_tx_data,
   gmii_tx_en, gmii_tx_er
   );
    input rgmii_rx_clk;
    input rgmii_rx_ctrl;
    input [3:0] rgmii_rxd;

    output reg	rgmii_tx_clk;
    output reg	rgmii_tx_ctrl;
    output reg	sec_ctrl;
    output reg	sec_q;
    output reg [3:0] rgmii_txd;

   input 	     gmii_tx_clk;
   input [7:0] 	     gmii_tx_data;
   input 	     gmii_tx_en;
   input 	     gmii_tx_er;

   output 	     gmii_rx_clk;
   output [7:0]      gmii_rx_data;
   output 	     gmii_rx_en;
   output 	     gmii_rx_er;


   output 	     sec_ctrl, sec_q;
	  

    always @(*)
      rgmii_tx_clk = clk;

    genvar 	 i;
    generate
	for(i=0; i<4; i++) begin : txd 
	  ODDRX1F txd(
		      .D0(gmii_tx_data[i]),
		      .D1(gmii_tx_data[i+4]),
		      .RST(rst),
		      .SCLK(clk),
		      .Q(rgmii_txd[i]));
	end
    endgenerate
    ODDRX1F ctrl(
		 .D0(gmii_tx_en),
		 .D1(gmii_tx_en ^ gmii_tx_er),
		 .RST(rst),
		 .SCLK(clk),
		 .Q(rgmii_tx_ctrl));
    ODDRX1F secctrl(
		 .D0(gmii_tx_en ^ gmii_tx_er),
		 .D1(gmii_tx_en ^ gmii_tx_er),
		 .RST(rst),
		 .SCLK(clk),
		 .Q(sec_ctrl));
    ODDRX1F secq(
		.D0(rgmii_tx_data[0]),
		.D1(rgmii_tx_data[4]),
		.RST(rst),
		.SCLK(clk),
		.Q(sec_q));
    
    

endmodule

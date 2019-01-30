`default_nettype wire
module gmii_to_rgmii(/*AUTOARG*/
   // Outputs
   rgmii_tx_clk, rgmii_tx_ctrl, sec_ctrl, sec_q, rgmii_txd,
   gmii_rx_clk, gmii_rx_data, gmii_rx_en, gmii_rx_er,
   // Inputs
   rgmii_rx_clk, rgmii_rx_ctrl, rgmii_rxd, gmii_tx_clk, gmii_tx_data,
   gmii_tx_en, gmii_tx_er, gmii_tx_rst
   );
    input rgmii_rx_clk;
    input rgmii_rx_ctrl;
    input [3:0] rgmii_rxd;

    output reg	rgmii_tx_clk;
    output wire	rgmii_tx_ctrl;
    output wire	sec_ctrl;
    output wire	sec_q;
    output wire [3:0] rgmii_txd;

   input 	     gmii_tx_clk;
   input [7:0] 	     gmii_tx_data;
   input 	     gmii_tx_en;
   input 	     gmii_tx_er;
   input 	     gmii_tx_rst;

   output 	     gmii_rx_clk;
   output [7:0]      gmii_rx_data;
   output 	     gmii_rx_en;
   output 	     gmii_rx_er;


	  

    always @(*)
      rgmii_tx_clk = gmii_tx_clk;

    genvar 	 i;
    generate
	for(i=0; i<4; i=i+1) begin : txd 
	  ODDRX1F txd(
		      .D0(gmii_tx_data[i]),
		      .D1(gmii_tx_data[i+4]),
		      .RST(gmii_tx_rst),
		      .SCLK(gmii_tx_clk),
		      .Q(rgmii_txd[i]));
	end
    endgenerate
    ODDRX1F ctrl(
		 .D0(gmii_tx_en),
		 .D1(gmii_tx_en ^ gmii_tx_er),
		 .RST(gmii_tx_rst),
		 .SCLK(gmii_tx_clk),
		 .Q(rgmii_tx_ctrl));
    ODDRX1F secctrl(
		 .D0(gmii_tx_en ^ gmii_tx_er),
		 .D1(gmii_tx_en ^ gmii_tx_er),
		 .RST(gmii_tx_rst),
		 .SCLK(gmii_tx_clk),
		 .Q(sec_ctrl));
    ODDRX1F secq(
		.D0(gmii_tx_data[0]),
		.D1(gmii_tx_data[4]),
		.RST(gmii_tx_rst),
		.SCLK(gmii_tx_clk),
		.Q(sec_q));
    
    

endmodule

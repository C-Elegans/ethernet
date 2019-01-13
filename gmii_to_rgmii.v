module gmii_to_rgmii(/*AUTOARG*/
    // Outputs
    rgmii_tx_clk, rgmii_tx_ctrl, rgmii_txd,
    // Inputs
    rgmii_rx_clk, rgmii_rx_ctrl, rgmii_rxd, clk, rst
    );
    input rgmii_rx_clk;
    input rgmii_rx_ctrl;
    input [3:0] rgmii_rxd;

    output reg	rgmii_tx_clk;
    output reg	rgmii_tx_ctrl;
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
    always @(posedge clk) begin
	if(rst == 1) begin
	    en <= 0;
	    ctr <= 0;
	    /*AUTORESET*/
	end
	else begin
	    ctr <= ctr + 1;
	    en <= 0;
	    if(ctr == 0) begin
		en <= 1;
	    end
	    else if(ctr == 1) begin
	      en <= 0;
	    end
	    
	    

	end
    end

    always @(posedge clk) begin
	if(ctr == 0) begin
	    rgmii_txd <= tx_en ? tx_data[3:0] : 0;
	    txd_next <= tx_en ? tx_data[7:4] : 0;
	end
	if(ctr == 1)begin
	    rgmii_txd <= txd_next;
	end
	rgmii_tx_ctrl <= tx_en;
    end

    reg [10:0] counter;
    reg [7:0] frame [0:127];
    initial $readmemh("frame.hex", frame);
    always @(posedge clk) begin
	if(rst == 1) begin
	    /*AUTORESET*/
	    // Beginning of autoreset for uninitialized flops
	    counter <= 7'h0;
	    tx_data <= 8'h0;
	    tx_en <= 1'h0;
	    // End of automatics
	end
	else if(en == 1) begin
	    counter <= counter + 1;
	    tx_en <= counter > 0 && counter <= 71;
	    tx_data <= frame[counter[6:0]];

	end
    end
    
    
    


endmodule // gmii_to_rgmii


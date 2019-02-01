module reset(/*AUTOARG*/
    // Outputs
    rgmii_rstn, mac_rst,
    // Inputs
    clk, rstn, pll_lock
    );
    input clk, rstn, pll_lock;

    output reg rgmii_rstn;
    output reg mac_rst;
    

    reg [19:0] counter;

    always @(posedge clk) begin
	if(rstn == 1'b0 || pll_lock == 0) begin
	    counter <= 0;
	    rgmii_rstn <= 0;
	    mac_rst <= 1;
	end
	else begin
	   `ifndef VERILATOR
	    counter <= counter + 1;
	    if(counter == 20'h10000)
	       `endif
	      rgmii_rstn <= 1;
	   `ifndef VERILATOR
	    if(counter == 20'h20000) 
	   `endif
	      mac_rst <= 0;
	end
    end
    

endmodule // reset

module mac(/*AUTOARG*/
   // Outputs
   rgmii_tx_clk, rgmii_txd, rgmii_tx_ctrl, sec_q, sec_ctrl, o_wb_ack,
   o_wb_stall, o_wb_data,
   // Inputs
   rgmii_rx_clk, rgmii_rxd, rgmii_rx_ctrl, tx_clk, core_clk, rst,
   i_wb_cyc, i_wb_stb, i_wb_we, i_wb_addr, i_wb_data
   );
   output rgmii_tx_clk;
   output [3:0] rgmii_txd;
   output 	rgmii_tx_ctrl;

   input 	rgmii_rx_clk;
   input [3:0]	rgmii_rxd;
   input 	rgmii_rx_ctrl;

   output 	sec_q, sec_ctrl;


   input 	tx_clk;
   input 	core_clk;
   input 	rst;
   input 	i_wb_cyc, i_wb_stb, i_wb_we;
   input [1:0] 	i_wb_addr;
   input [7:0] 	i_wb_data;
   output 	o_wb_ack;
   output 	o_wb_stall;
   output [7:0]	o_wb_data;

   wire 	gmii_tx_clk = tx_clk;
   wire 	gmii_tx_rst = rst;


   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			gmii_rx_clk;		// From rgmii of gmii_to_rgmii.v
   wire [7:0]		gmii_rx_data;		// From rgmii of gmii_to_rgmii.v
   wire			gmii_rx_en;		// From rgmii of gmii_to_rgmii.v
   wire			gmii_rx_er;		// From rgmii of gmii_to_rgmii.v
   // End of automatics
   wire [7:0]		o_fifo_data;		// From wb of wb_interface.v
   wire			o_fifo_wr;		// From wb of wb_interface.v
   wire [10:0]		o_word_count;		// From wb of wb_interface.v
   wire			word_count_ready;	// From wb of wb_interface.v
   wire			word_count_ack;		// From gmii of gmii_interface.v
   wire			fifo_rd;		// From gmii of gmii_interface.v
   wire [7:0]		gmii_tx_data;		// From gmii of gmii_interface.v
   wire			gmii_tx_en;		// From gmii of gmii_interface.v
   wire			gmii_tx_er;		// From gmii of gmii_interface.v
   wire [7:0] 		o_rdata;		// From fifo of afifo.v
   wire			o_rempty;		// From fifo of afifo.v
   wire			o_wfull;		// From fifo of afifo.v
   wb_interface wb(
		   // Outputs
		   .o_wb_ack		(o_wb_ack),
		   .o_wb_stall		(o_wb_stall),
		   .o_wb_data		(o_wb_data[7:0]),
		   .o_fifo_wr		(o_fifo_wr),
		   .o_fifo_data		(o_fifo_data[7:0]),
		   .o_word_count	(o_word_count[10:0]),
		   .word_count_ready	(word_count_ready),
		   // Inputs
		   .clk			(core_clk),
		   .rst			(rst),
		   .i_wb_cyc		(i_wb_cyc),
		   .i_wb_stb		(i_wb_stb),
		   .i_wb_we		(i_wb_we),
		   .i_wb_addr		(i_wb_addr[1:0]),
		   .i_wb_data		(i_wb_data[7:0]),
		   .i_fifo_full		(o_wfull),
		   .word_count_ack	(word_count_ack));

   afifo #(
	   .DSIZE(8),
	   .ASIZE(9)
	   )fifo(
	      // Outputs
	      .o_wfull			(o_wfull),
	      .o_rdata			(o_rdata[7:0]),
	      .o_rempty			(o_rempty),
	      // Inputs
	      .i_wclk			(core_clk),
	      .i_wrst_n			(~rst),
	      .i_wr			(o_fifo_wr),
	      .i_wdata			(o_fifo_data[7:0]),
	      .i_rclk			(tx_clk),
	      .i_rrst_n			(~rst),
	      .i_rd			(fifo_rd));

   gmii_interface gmii(
		       // Outputs
		       .fifo_rd		(fifo_rd),
		       .word_count_ack	(word_count_ack),
		       .gmii_tx_data	(gmii_tx_data[7:0]),
		       .gmii_tx_en	(gmii_tx_en),
		       .gmii_tx_er	(gmii_tx_er),
		       // Inputs
		       .clk		(tx_clk),
		       .rst		(gmii_tx_rst),
		       .fifo_data	(o_rdata[7:0]),
		       .fifo_empty	(o_rempty),
		       .word_count	(o_word_count[10:0]),
		       .word_count_ready(word_count_ready));

   gmii_to_rgmii rgmii(/*AUTOINST*/
		       // Outputs
		       .rgmii_tx_clk	(rgmii_tx_clk),
		       .rgmii_tx_ctrl	(rgmii_tx_ctrl),
		       .sec_ctrl	(sec_ctrl),
		       .sec_q		(sec_q),
		       .rgmii_txd	(rgmii_txd[3:0]),
		       .gmii_rx_clk	(gmii_rx_clk),
		       .gmii_rx_data	(gmii_rx_data[7:0]),
		       .gmii_rx_en	(gmii_rx_en),
		       .gmii_rx_er	(gmii_rx_er),
		       // Inputs
		       .rgmii_rx_clk	(rgmii_rx_clk),
		       .rgmii_rx_ctrl	(rgmii_rx_ctrl),
		       .rgmii_rxd	(rgmii_rxd[3:0]),
		       .gmii_tx_clk	(gmii_tx_clk),
		       .gmii_tx_data	(gmii_tx_data[7:0]),
		       .gmii_tx_en	(gmii_tx_en),
		       .gmii_tx_er	(gmii_tx_er),
		       .gmii_tx_rst	(gmii_tx_rst));

endmodule // mac

module gmii_interface(/*AUTOARG*/
   // Outputs
   fifo_rd, word_count_ack, gmii_tx_data, gmii_tx_en, gmii_tx_er,
   // Inputs
   clk, rst, fifo_data, fifo_empty, word_count, word_count_ready
   );

   input clk, rst;

   input [7:0] fifo_data;
   input       fifo_empty;
   output      fifo_rd;

   input [10:0] word_count;
   input 	word_count_ready;
   output reg 	word_count_ack;

   output reg [7:0] gmii_tx_data;
   output reg 	    gmii_tx_en;
   output reg 	    gmii_tx_er;

   

   localparam //auto enum state
     S_IDLE=0,
     S_HEADER=1,
     S_BODY=2;
   reg //auto enum state
       [1:0] state;

   reg [10:0] word_count_reg;
   reg [2:0]  wc_ready_sync;

   reg [2:0]  header_len;

   always @(posedge clk) begin
      if(rst == 1) begin
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 fifo_rd <= 1'h0;
	 gmii_tx_data <= 8'h0;
	 gmii_tx_en <= 1'h0;
	 header_len <= 3'h0;
	 state <= 2'h0;
	 word_count_ack <= 1'h0;
	 word_count_reg <= 11'h0;
	 // End of automatics
      end
      else begin
	 wc_ready_sync <= {wc_ready_sync[1:0], word_count_ready};
	 if(wc_ready_sync[2] == 0 && word_count_ack == 1)
	   word_count_ack <= 0;
	 case(state)
	   S_IDLE: begin
	      gmii_tx_en <= 1'b0;
	      gmii_tx_data <= 8'b0;
	      if(wc_ready_sync[2]) begin
		 word_count_ack <= 1;
		 word_count_reg <= word_count;
		 state <= S_HEADER;
		 header_len <= 3'd7;
	      end
	   end
	   S_HEADER: begin
	      gmii_tx_en <= 1;
	      gmii_tx_data <= 8'h55;
	      header_len <= header_len - 1;
	      if(header_len == 3'b0) begin
		 gmii_tx_data <= 8'h5d;
		 state <= S_BODY;
		 fifo_rd <= 1'b1;
	      end
	   end

	   S_BODY: begin
	      word_count_reg <= word_count_reg - 1;
	      gmii_tx_data <= fifo_data;
	      if(word_count_reg == 0) begin
		 state <= S_IDLE;
		 fifo_rd <= 1'b0;
	      end
	   end
	   
	      
	   
	 endcase // case (state)
      end
   end
   


endmodule // gmii_interface

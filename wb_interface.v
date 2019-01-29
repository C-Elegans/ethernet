module wb_interface(/*AUTOARG*/
   // Outputs
   o_wb_ack, o_wb_stall, o_wb_data, o_fifo_wr, o_fifo_data,
   o_word_count, word_count_ready,
   // Inputs
   clk, rst, i_wb_cyc, i_wb_stb, i_wb_we, i_wb_addr, i_wb_data,
   i_fifo_full, word_count_ack
   );
    input clk, rst;
    input wire i_wb_cyc;
    input wire i_wb_stb;
    input wire i_wb_we;
    input [1:0] i_wb_addr;
    input [7:0] i_wb_data;

    output reg	 o_wb_ack;
    output 	 o_wb_stall;
    output reg [7:0] o_wb_data;

    input 	  i_fifo_full;
    output reg	  o_fifo_wr;
    output reg [7:0] o_fifo_data;

   output reg [10:0] o_word_count;
   output reg 	     word_count_ready;
   input 	     word_count_ack;

   reg [2:0] 	     wc_ack_sync;

    reg [10:0] 	      word_count;

      assign o_wb_stall = i_fifo_full || state != S_WRITING;

   wire [31:0] 	      crc32_out;
   wire 	      crc32_rst;
   reg 		      crc32_en;
   reg [7:0] 	      crc32_data_in;
   reg 		      crc32_rst_reg;

   assign crc32_rst = rst | crc32_rst_reg;
   

   crc32 crc_inst(
	     // Outputs
	     .crc			(crc32_out[31:0]),
	     // Inputs
	     .clk			(clk),
	     .rst			(crc32_rst),
	     .en			(crc32_en),
	     .data_in			(crc32_data_in[7:0]));


   localparam // auto enum state
     S_IDLE=0,
     S_WRITING=1,
     S_CRC_0=2,
     S_CRC_1=3,
     S_CRC_2=4,
     S_CRC_3=5,
     S_WC_SEND=6,
     S_WC_ACK=7;

   reg [2:0] // auto enum state
	     state;

   wire      wb_write = i_wb_stb && i_wb_we && !o_wb_stall;
   wire      wb_read = i_wb_stb && !i_wb_we && !o_wb_stall;

    always @(posedge clk) begin
	if(rst) begin
	    /*AUTORESET*/
	    // Beginning of autoreset for uninitialized flops
	    crc32_data_in <= 8'h0;
	    crc32_en <= 1'h0;
	    crc32_rst_reg <= 1'h0;
	    o_fifo_data <= 8'h0;
	    o_fifo_wr <= 1'h0;
	    o_wb_ack <= 1'h0;
	    o_wb_data <= 8'h0;
	    o_word_count <= 11'h0;
	    state <= 3'h0;
	    wc_ack_sync <= 3'h0;
	    word_count <= 11'h0;
	    word_count_ready <= 1'h0;
	    // End of automatics
	end
	else begin 
	    o_fifo_wr <= 1'b0;
	    o_wb_ack <= 0;
	   wc_ack_sync <= {wc_ack_sync[1:0], word_count_ack};
	    // write
	    if(wb_write) begin
		if(i_wb_addr == 2'b0) begin
		   o_fifo_data <= i_wb_data;
		   o_fifo_wr <= 1'b1;
		end
	       else if(i_wb_addr == 2'b01) begin
		  word_count <= {3'b0, i_wb_data[7:0]};
	       end
	       else if(i_wb_addr == 2'b10) begin
		  word_count <= {i_wb_data[2:0], word_count[7:0]};
	       end
	       o_wb_ack <= 1'b1;
	    end // if (i_wb_stb && i_wb_we && !i_fifo_full)

	    // read
	    if(wb_read) begin
	       if(i_wb_addr == 2'b1)
		 o_wb_data <= word_count[7:0];
	       else if(i_wb_addr == 2'b10)
		 o_wb_data <= {5'b0, word_count[10:8]};
	       else
		 o_wb_data <= 8'b0;
	       o_wb_ack <= 1;
	    end
	   case(state)
	     S_IDLE: begin
		crc32_rst_reg <= 1'b1;
		state <= S_WRITING;
	     end
	     S_WRITING: begin
		crc32_rst_reg <= 1'b0;
		crc32_en <= 1'b0;
		if(wb_write && i_wb_addr == 2'b0) begin
		   crc32_data_in <= i_wb_data;
		   crc32_en <= 1'b1;
		end
		if(wb_write && i_wb_addr == 2'b11) begin
		   state <= S_CRC_0;
		end
	     end
	     S_CRC_0: begin
		o_fifo_wr <= 1'b1;
		o_fifo_data <= crc32_out[7:0];
		state <= S_CRC_1;
	     end
	     S_CRC_1: begin
		o_fifo_wr <= 1'b1;
		o_fifo_data <= crc32_out[15:8];
		state <= S_CRC_2;
	     end
	     S_CRC_2: begin
		o_fifo_wr <= 1'b1;
		o_fifo_data <= crc32_out[23:16];
		state <= S_CRC_3;
	     end
	     S_CRC_3: begin
		o_fifo_wr <= 1'b1;
		o_fifo_data <= crc32_out[31:24];
		state <= S_WC_SEND;
	     end
	     S_WC_SEND: begin
		o_word_count <= word_count;
		word_count_ready <= 1'b1;
	     end
	     S_WC_ACK: 
	       if(wc_ack_sync[2]) begin
		  word_count_ready <= 1'b0;
		  state <= S_IDLE;
	       end
	     
	     
	     
	   endcase // case (state)
	   
	end // else: !if(rst)
    end // always @ (posedge clk)

   
`ifdef FORMAL
   reg f_past_valid;
   initial f_past_valid = 1'b0;
   initial assume(i_wb_stb == 0);
   initial assume(rst == 1);
   always @(posedge clk) begin
      if(rst == 0)
	f_past_valid = 1'b1;
      if(f_past_valid)
	assume(rst == 0);
   end
   
   always @(posedge clk) begin
      cover(i_fifo_full && i_wb_stb);
      cover(i_wb_stb && i_wb_we && !o_wb_stall);
      cover(i_wb_stb && !i_wb_we && !o_wb_stall && word_count != 0);
      cover($past(word_count) != word_count && f_past_valid);
      cover(o_wb_data == $past(word_count) && f_past_valid && ($past(o_wb_data) != $past(word_count)));
   end
   
   

   // Prove that it will never overflow the fifo
   always @(posedge clk) begin
      if($past(i_fifo_full) && f_past_valid)
	assert(!o_fifo_wr);
   end
   // Prove that it always acks as long as it wasn't previously stalling
   always @(posedge clk) begin
      if($past(i_wb_stb) && f_past_valid && !$past(o_wb_stall))
	assert(o_wb_ack);
   end
   
`endif
endmodule // wb_interface


module wb_interface(/*AUTOARG*/
    // Outputs
    o_wb_ack, o_wb_stall, o_wb_data, o_fifo_wr, o_fifo_data,
    // Inputs
    clk, rst, i_wb_cyc, i_wb_stb, i_wb_we, i_wb_addr, i_wb_data,
    i_fifo_full
    );
    input clk, rst;
    input wire i_wb_cyc;
    input wire i_wb_stb;
    input wire i_wb_we;
    input      i_wb_addr;
    input [31:0] i_wb_data;

    output reg	 o_wb_ack;
    output 	 o_wb_stall;
    output reg [31:0] o_wb_data;

    input 	  i_fifo_full;
    output reg	  o_fifo_wr;
    output reg [31:0] o_fifo_data;

    reg [8:0] 	      word_count;

      assign o_wb_stall = i_fifo_full;
    

    always @(posedge clk) begin
	if(rst) begin
	    /*AUTORESET*/
	    // Beginning of autoreset for uninitialized flops
	    o_fifo_data <= 32'h0;
	    o_fifo_wr <= 1'h0;
	    o_wb_ack <= 1'h0;
	    o_wb_data <= 32'h0;
	    word_count <= 9'h0;
	    // End of automatics
	end
	else begin 
	    o_fifo_wr <= 1'b0;
	    o_wb_ack <= 0;
	    // write
	    if(i_wb_stb && i_wb_we && !o_wb_stall) begin
		case(i_wb_addr) 
		  1'b0: begin
		      o_fifo_data <= i_wb_data;
		      o_fifo_wr <= 1'b1;
		  end
		  1'b1: begin
		      word_count <= i_wb_data[8:0];
		  end
		endcase // case (i_wb_addr)
		o_wb_ack <= 1'b1;
	    end // if (i_wb_stb && i_wb_we && !i_fifo_full)

	    // read
	    if(i_wb_stb && !i_wb_we && !o_wb_stall) begin
		o_wb_data <= {23'b0, word_count};
		o_wb_ack <= 1;
	    end
	    
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


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

    output 	 o_wb_ack;
    output 	 o_wb_stall;
    output [31:0] o_wb_data;

    input 	  i_fifo_full;
    output reg	  o_fifo_wr;
    output reg [31:0] o_fifo_data;

    reg [8:0] 	      word_count;

    always @(*)
      o_wb_stall = i_fifo_full;
    

    always @(posedge clk) begin
	if(rst) begin
	    /*AUTORESET*/
	    // Beginning of autoreset for uninitialized flops
	    o_fifo_data <= 32'h0;
	    o_fifo_wr <= 1'h0;
	    // End of automatics
	end
	else begin 
	    o_fifo_wr <= 1'b0;
	    o_wb_ack <= 0;
	    // write
	    if(i_wb_stb && i_wb_we && !i_fifo_full) begin
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
    
    

endmodule // wb_interface


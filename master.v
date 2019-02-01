module master(/*AUTOARG*/
   // Outputs
   o_wb_cyc, o_wb_stb, o_wb_we, o_wb_addr, o_wb_data,
   // Inputs
   clk, rst, i_wb_ack, i_wb_stall, i_wb_data
   );
   input clk, rst;

   output reg o_wb_cyc;
   output reg o_wb_stb;
   output reg o_wb_we;
   output reg [1:0] o_wb_addr;
   output reg [7:0] o_wb_data;

   input 	    i_wb_ack;
   input 	    i_wb_stall;
   input [7:0] 	    i_wb_data;

   reg [7:0] 	    mem [0:255];
   initial $readmemh("frame.hex", mem);
   parameter MSG_LEN=64;
   parameter CTR_MAX=10000;

   localparam //auto enum state
     S_INIT=0,
     S_SEND_MSG=1,
     S_WRITE_LEN=2,
     S_SEND=3,
     S_WAIT=4;
   reg [2:0]  //auto enum state
	     state;

   reg [17:0] counter;
   reg [7:0]  ptr;

   always @(posedge clk) begin
      if(rst) begin
	 state <= S_INIT;
	 /*AUTORESET*/
	 // Beginning of autoreset for uninitialized flops
	 counter <= 18'h0;
	 o_wb_addr <= 2'h0;
	 o_wb_cyc <= 1'h0;
	 o_wb_data <= 8'h0;
	 o_wb_stb <= 1'h0;
	 o_wb_we <= 1'h0;
	 ptr <= 8'h0;
	 // End of automatics
      end
      else if(!i_wb_stall) begin
	 o_wb_cyc <= 0;
	 o_wb_stb <= 0;
	 o_wb_we <= 0;
	 case(state)
	   S_INIT: begin
	      state <= S_SEND_MSG;
	      ptr <= 0;
	   end
	   S_SEND_MSG: begin
	      o_wb_cyc <= 1'b1;
	      o_wb_stb <= 1'b1;
	      o_wb_addr <= 2'b0;
	      o_wb_we <= 1'b1;
	      o_wb_data <= mem[ptr];
	      ptr <= ptr + 1;
	      if(ptr == MSG_LEN-5)
		state <= S_WRITE_LEN;
	   end
	   S_WRITE_LEN: begin
	      o_wb_cyc <= 1'b1;
	      o_wb_stb <= 1'b1;
	      o_wb_addr <= 2'b1;
	      o_wb_we <= 1'b1;
	      o_wb_data <= MSG_LEN-1;
	      state <= S_SEND;
	   end
	   S_SEND: begin
	      o_wb_cyc <= 1'b1;
	      o_wb_stb <= 1'b1;
	      o_wb_addr <= 2'd3;
	      o_wb_we <= 1'b1;
	      o_wb_data <= 0;
	      state <= S_WAIT;
	   end
	   S_WAIT: begin
	      counter <= counter + 1;
	      if(counter >= CTR_MAX) begin
		 state <= S_INIT;
		 counter <= 0;
	      end
	   end
	   
	   
      
	   
	 endcase // case (state)
      end
   end
   
endmodule // master

   

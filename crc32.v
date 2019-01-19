module crc32(/*AUTOARG*/
    // Outputs
    crc,
    // Inputs
    clk, rst, en, data_in
    );
    input clk, rst;
    input en;
    input [7:0] data_in;
    output [31:0] crc;

    reg [31:0] 	  state;
    assign crc = state ^ 32'hffffffff;
    reg [31:0] 	  temp;

    int 	  i;
    always @(posedge clk)
      if(rst == 1'b1) begin
	  state <= 32'hffffffff;
	  /*AUTORESET*/
      end
      else if(en == 1) begin

	  state <= temp;
      end

    always @(*) begin
	temp = state ^ {24'b0, data_in};
	for (i=0;i<8;i++)
	  if((temp & 32'b1) != 0)
	    temp = (temp >> 1) ^ 32'hedb88320;
	  else
	    temp = (temp >> 1);
    end
    
    

endmodule // crc32
/* crc calculation
def crc32(frame):
    crc = 0xffffffff
    for byte in frame:
        crc ^= byte
        for i in range(0,8):
            if crc & 1:
                crc = (crc >> 1) ^ 0xedb88320
            else:
                crc = crc >> 1
    crc = crc ^ 0xffffffff
    return [crc & 0xff, (crc >> 8) & 0xff, (crc >> 16) & 0xff, (crc >> 24) & 0xff]

*/

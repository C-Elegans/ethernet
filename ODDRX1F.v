// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2005 by Lattice Semiconductor Corporation
// --------------------------------------------------------------------
//
//
//                     Lattice Semiconductor Corporation
//                     5555 NE Moore Court
//                     Hillsboro, OR 97214
//                     U.S.A.
//
//                     TEL: 1-800-Lattice  (USA and Canada)
//                          1-408-826-6000 (other locations)
//
//                     web: http://www.latticesemi.com/
//                     email: techsupport@latticesemi.com
//
// --------------------------------------------------------------------
//
// Simulation Library File for ODDRX1F in ECP5U/M, LIFMD
//
`resetall
`timescale 1 ns / 1 ps

`celldefine

module ODDRX1F(D0, D1, RST, SCLK, Q);
    input D0, D1, RST, SCLK;
    output Q;

    reg [1:0] pipe_1, pipe_2, pipe_3;

    assign Q = SCLK ? pipe_3[1] : pipe_3[0];
    always @(posedge SCLK) begin
	pipe_1 <= {D0, D1};
	pipe_2 <= pipe_1;
	pipe_3 <= pipe_2;
    end

    
endmodule // ODDRX1F

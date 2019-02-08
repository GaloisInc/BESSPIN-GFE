`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Galois, Inc.
// Engineer: Christine Goins
// 
// Create Date: 02/06/2019 12:02:09 PM
// Design Name: Input/Output Buffer (Xilinx primitive)
// Module Name: iobuf
// Project Name: 
// Target Devices: VCU118
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module iobuf(
    input I,
    inout IO,
    output O,
    input T
    );
    
    // IOBUF: Simple Bi-directional Buffer
    // UltraScale
    // Xilinx HDL Libraries Guide, version 2014.1
    IOBUF #(
    )
    IOBUF_inst (
    .O(O), // 1-bit output: Buffer output
    .I(I), // 1-bit input: Buffer input
    .IO(IO), // 1-bit inout: Buffer inout (connect directly to top-level port)
    .T(T) // 1-bit input: 3-state enable input
    );
    // End of IOBUF_inst instantiation
    
endmodule

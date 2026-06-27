`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2026 14:31:58
// Design Name: 
// Module Name: cla8
// Project Name: 
// Target Devices: 
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


module cla8(
        input [7:0] A, 
        input [7:0] B, 
        input       Cin, 
        
        output [7:0] S,
        output       Cout
    );
    
    wire t1;
    
    cla4 CLA0(.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .S(S[3:0]), .Cout(t1));
    cla4 CLA1(.A(A[7:4]), .B(B[7:4]), .Cin(t1), .S(S[7:4]), .Cout(Cout));
    
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2026 14:59:21
// Design Name: 
// Module Name: cla32
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


module cla32(
        input [31:0] A,
        input [31:0] B, 
        input        Cin,
        
        output [31:0] S,
        output        Cout
    );
    
    wire t1, t2, t3;
    
    cla8 CLA0(
            .A(A[7:0]), 
            .B(B[7:0]), 
            .Cin(Cin), 
            .S(S[7:0]), 
            .Cout(t1)
            );
            
    cla8 CLA1(
            .A(A[15:8]), 
            .B(B[15:8]), 
            .Cin(t1), 
            .S(S[15:8]), 
            .Cout(t2)
            );
            
    cla8 CLA2(
            .A(A[23:16]), 
            .B(B[23:16]), 
            .Cin(t2), 
            .S(S[23:16]), 
            .Cout(t3)
            );
            
    cla8 CLA3(
            .A(A[31:24]), 
            .B(B[31:24]), 
            .Cin(t3), 
            .S(S[31:24]), 
            .Cout(Cout)
            );
    
endmodule

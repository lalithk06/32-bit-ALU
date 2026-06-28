`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2026 14:13:00
// Design Name: 
// Module Name: cla4
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


module cla4(
        input [3:0] A,
        input [3:0] B,
        input       Cin,
        
        output [3:0] S,
        output       Cout
    );
    
    wire [3:0] C;   
    wire [3:0] G, P;
    
    assign G = A & B;
    assign P = A ^ B; 
    
    assign C[0] = Cin;
    assign C[1] = G[0] | (P[0] & Cin); 
    assign C[2] = G[1] | (P[1] & (G[0] | (P[0] & Cin)));
    assign C[3] = G[2] | (P[2] & (G[1] | (P[1] & (G[0] | (P[0] & Cin)))));
    assign Cout = G[3] | (P[3] & (G[2] | (P[2] & (G[1] | (P[1] & (G[0] | (P[0] & Cin)))))));
    
    assign S = P ^ C;
    
endmodule

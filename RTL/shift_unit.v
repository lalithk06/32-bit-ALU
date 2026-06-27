`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2026 16:28:56
// Design Name: 
// Module Name: shift_unit
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


module shift_unit(
        input [31:0] A,
        input [4:0] sh_amt,       //5 bits to span a max. of 31 shifts
        input [2:0] opcode,
        
        output reg [31:0] Result
    );
    
    localparam SHIFT_LL = 3'b000;
    localparam SHIFT_RL = 3'b001;
    localparam SHIFT_RA = 3'b010;
     
    always @(*) begin
        case(opcode)
            SHIFT_LL:
            begin
                Result = A << sh_amt;
            end
            
            SHIFT_RL:
            begin
                Result = A >> sh_amt;
            end
            
            SHIFT_RA:
            begin
                Result = A >>> sh_amt;
            end
            
            default: 
            begin
                Result = 32'b0;
            end
            
        endcase
    end
endmodule

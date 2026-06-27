`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2026 16:18:02
// Design Name: 
// Module Name: logical_unit
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


module logical_unit(
        input [31:0] A,
        input [31:0] B,
        input [2:0] opcode,
        input logic_enable,
        
        output reg [31:0] Result
    );
    
    localparam AND  = 3'b000;
    localparam OR   = 3'b001;
    localparam NOT  = 3'b010;
    localparam XOR  = 3'b011;
    localparam NAND = 3'b100;
    localparam NOR  = 3'b101;
    localparam XNOR = 3'b110;
    
    always @(*) begin
        if(!logic_enable) begin
            Result = 32'b0;
        end
        
        else begin
            case(opcode)
                AND:
                begin 
                    Result = A & B;
                end 
                
                OR:
                begin 
                    Result = A | B;
                end 
                
                NOT:
                begin 
                    Result = ~A;
                end 
                
                XOR:
                begin 
                    Result = A ^ B;
                end 
                
                NAND:
                begin 
                    Result = ~(A & B);
                end 
                
                NOR:
                begin 
                    Result = ~(A | B);
                end 
                
                XNOR:
                begin 
                    Result = ~(A ^ B);
                end 
                
                default:
                begin 
                    Result = 32'b0;
                end 
                
            endcase
        end
    end
endmodule

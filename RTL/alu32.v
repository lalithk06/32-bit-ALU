`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2026 16:55:33
// Design Name: 
// Module Name: alu32
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


module alu32(
        input [31:0] A,
        input [31:0] B,
        input [4:0]  alu_opcode,
        
        output reg [31:0] Result,
        output Z, N, C, P, V
     );
    
    reg [2:0] op_sel;
    
    wire [31:0] arith_result;
    wire [31:0] logic_result;
    wire [31:0] shift_result;
    wire arith_Cout;
    wire arith_Overflow;
    
    reg arith_enable;
    reg logic_enable;
    reg shift_enable;
    
    localparam ARITHMETIC = 2'b00;
    localparam LOGICAL = 2'b01;
    localparam SHIFT = 2'b10;
    
    arithmetic_unit AU(
            .A(A), 
            .B(B), 
            .opcode(op_sel), 
            .arith_enable(arith_enable), 
            .Result(arith_result), 
            .Cout(arith_Cout),
            .V(arith_Overflow)
            );
            
    logical_unit    LU(
            .A(A), 
            .B(B), 
            .opcode(op_sel), 
            .logic_enable(logic_enable), 
            .Result(logic_result)
            );
            
    shift_unit      SU(
            .A(A), 
            .sh_amt(B[4:0]), 
            .opcode(op_sel), 
            .shift_enable(shift_enable), 
            .Result(shift_result)
            );
            
      
    always @(*) begin
    
         op_sel = alu_opcode[2:0];
         
         arith_enable = 1'b0;
         logic_enable = 1'b0;
         shift_enable = 1'b0;
    
        case(alu_opcode[4:3])
            ARITHMETIC:
            begin
                arith_enable = 1'b1;
            end
            
            LOGICAL:
            begin
                logic_enable = 1'b1;
            end
            
            SHIFT:
            begin
                shift_enable = 1'b1;
            end
            
            default:
            begin
                op_sel = 3'b000;
            end
        endcase
    end
    
    always @(*) begin
        case(alu_opcode[4:3])
            ARITHMETIC:
            begin
                Result = arith_result;
            end
            
            LOGICAL:
            begin
                Result = logic_result;
            end
            
            SHIFT:
            begin
                Result = shift_result;
            end
            
            default:
            begin
                Result = 32'b0;
            end
        endcase
    end
    
    assign Z = (Result == 32'b0)? 1'b1 : 1'b0;
    assign C = (alu_opcode[4:3] == ARITHMETIC) ? arith_Cout : 1'b0;
    assign N = Result[31];
    assign P = ~^Result;
    assign V = (alu_opcode[4:3] == ARITHMETIC) ? arith_Overflow : 1'b0;
        
endmodule

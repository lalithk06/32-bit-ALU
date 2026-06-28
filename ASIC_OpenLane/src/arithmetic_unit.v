`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.06.2026 15:08:31
// Design Name: 
// Module Name: arithmetic_unit
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


module arithmetic_unit(
        input [31:0] A,
        input [31:0] B,
        input [2:0] opcode,
        input arith_enable,
        
        output reg [31:0] Result,
        output reg        Cout, V
    );
    
    reg [31:0] cla_A, cla_B;
    reg        cla_Cin; 
    wire [31:0] cla_Result;
    wire cla_Cout;
    
    localparam ADD = 3'b000;
    localparam SUB = 3'b001;
    localparam INC = 3'b010;
    localparam DEC = 3'b011;
    localparam PASS_A = 3'b100;
    localparam PASS_B = 3'b101;
    
    
//--------------------------
// Operand Selection Logic
//--------------------------
    always @(*) begin
        if(!arith_enable) begin
            cla_A = 32'b0; 
            cla_B = 32'b0; 
            cla_Cin = 1'b0;
        end
        
        else begin
            case (opcode)
            
                ADD:
                begin
                    cla_A = A; 
                    cla_B = B; 
                    cla_Cin = 1'b0;
                end
                    
                SUB:
                begin
                    cla_A = A; 
                    cla_B = ~B; 
                    cla_Cin = 1'b1;
                end
                
                INC:
                begin   
                    cla_A = A; 
                    cla_B = 32'b0; 
                    cla_Cin = 1'b1;
                end
                
                DEC:
                begin
                    cla_A = A; 
                    cla_B = 32'hFFFFFFFF;
                    cla_Cin = 1'b0;
                end
                
                PASS_A:
                begin
                    cla_A = 32'b0;
                    cla_B = 32'b0;
                    cla_Cin = 1'b0;
                end
                
                PASS_B:
                begin
                    cla_A = 32'b0;
                    cla_B = 32'b0;
                    cla_Cin = 1'b0;
                end
                
                default:
                begin
                    cla_A    = 32'b0;
                    cla_B    = 32'b0;
                    cla_Cin  = 1'b0;
                end
            endcase
        end
    end


//--------------------------------
// 32-bit Carry Lookahead Adder
//--------------------------------
    cla32 adder32(
            .A(cla_A), 
            .B(cla_B), 
            .Cin(cla_Cin), 
            .S(cla_Result), 
            .Cout(cla_Cout)
            );


//-------------------------
// Output Selection Logic
//-------------------------  
     always @(*) begin
        if(!arith_enable) begin
            Result = 32'b0;
            Cout   = 1'b0;
            V      = 1'b0;
        end
        
        else begin
            case (opcode)
            
                ADD,
                SUB,
                INC,
                DEC:
                begin
                    Result = cla_Result;
                    Cout = cla_Cout;
                    V = (cla_A[31] == cla_B[31]) && (cla_Result[31] != cla_A[31]);
                end
                
                PASS_A:
                begin
                    Result = A;
                    Cout = 1'b0;
                    V = 1'b0;
                end
                
                PASS_B:
                begin
                    Result = B;
                    Cout = 1'b0;
                    V = 1'b0;
                end
                
                default:
                begin
                   Result   = 32'b0;
                    Cout     = 1'b0;
                end
            endcase
        end
    end
endmodule

`timescale 1ns / 1ps

module shift_unit(
        input [31:0] A,
        input [4:0] sh_amt,       //5 bits to span a max. of 31 shifts
        input [2:0] opcode,
        input shift_enable,
        
        output reg [31:0] Result
    );
    
    localparam SHIFT_LL = 3'b000;
    localparam SHIFT_RL = 3'b001;
    localparam SHIFT_RA = 3'b010;
     
    always @(*) begin
        if(!shift_enable) begin
            Result = 32'b0; 
        end
        
        else begin
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
    end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_arithmetic_unit
// Description: Directed edge-case testbench for arithmetic_unit.
//              Covers: signed overflow at all 4 boundary cases (ADD/SUB/INC/DEC),
//              carry-out vs overflow distinction, sign-mismatch (no false overflow),
//              normal operation, PASS_A/PASS_B, and disabled (arith_enable=0).
//////////////////////////////////////////////////////////////////////////////////
module tb_shift_unit;

    reg  [31:0] A;
    reg [4:0] sh_amt;
    reg  [2:0]  opcode;
    reg         shift_enable;

    wire [31:0] Result;
    
    integer errors;
    integer test_num;

    localparam SLL    = 3'b000;
    localparam SRL    = 3'b001;
    localparam SRA    = 3'b010;
    
    shift_unit DUT (
        .A(A), .sh_amt(sh_amt), .opcode(opcode), .shift_enable(shift_enable),
        .Result(Result)
    );

    task run_test;
        input [31:0] tA;
        input [4:0]  tsh_amt;
        input [2:0]  top;
        input        ten;
        input [31:0] exp_result;
    
        begin
            A            = tA;
            sh_amt       = tsh_amt;
            opcode       = top;
            shift_enable = ten;
    
            #1;
    
            test_num = test_num + 1;
    
            if(Result !== exp_result) begin
                errors = errors + 1;
                $display("FAIL [Test %0d]", test_num);
                $display("Opcode   = %b", top);
                $display("A        = %h", tA);
                $display("Shift    = %0d", tsh_amt);
                $display("Expected = %h", exp_result);
                $display("Got      = %h", Result);
                $display("--------------------------------");
            end
            else begin
                $display("PASS [Test %0d] op=%b A=%h sh=%0d -> Result=%h",
                          test_num, top, tA, tsh_amt, Result);
            end
        end
    endtask

    initial begin

        errors   = 0;
        test_num = 0;
        
        //====================================================
        // SLL
        //====================================================
        
        run_test(32'h00000001,0,SLL,1,32'h00000001);
        run_test(32'h00000001,1,SLL,1,32'h00000002);
        run_test(32'h00000001,31,SLL,1,32'h80000000);        
        run_test(32'hFFFFFFFF,1,SLL,1,32'hFFFFFFFE);        
        run_test(32'hAAAAAAAA,4,SLL,1,32'hAAAAAAA0);        
        run_test(32'h12345678,8,SLL,1,32'h34567800);
        
        //====================================================
        // SRL
        //====================================================
        
        run_test(32'h80000000,1,SRL,1,32'h40000000);        
        run_test(32'hFFFFFFFF,1,SRL,1,32'h7FFFFFFF);        
        run_test(32'h80000000,31,SRL,1,32'h00000001);        
        run_test(32'h12345678,4,SRL,1,32'h01234567);        
        run_test(32'h00000001,1,SRL,1,32'h00000000);
        
        //====================================================
        // SRA
        //====================================================
        
        run_test(32'h80000000,1,SRA,1,32'hC0000000);        
        run_test(32'hFFFFFFFF,1,SRA,1,32'hFFFFFFFF);        
        run_test(32'h7FFFFFFF,1,SRA,1,32'h3FFFFFFF);        
        run_test(32'h80000000,31,SRA,1,32'hFFFFFFFF);        
        run_test(32'h12345678,4,SRA,1,32'h01234567);
        
        //====================================================
        // Disabled
        //====================================================
        
        run_test(32'h12345678,4,SLL,0,32'h00000000);        
        run_test(32'h12345678,4,SRL,0,32'h00000000);        
        run_test(32'h12345678,4,SRA,0,32'h00000000);
        
        //====================================================
        // Invalid opcode
        //====================================================
        
        run_test(32'h12345678,4,3'b011,1,32'h00000000);   
        run_test(32'h12345678,4,3'b100,1,32'h00000000);        
        run_test(32'h12345678,4,3'b101,1,32'h00000000);        
        run_test(32'h12345678,4,3'b110,1,32'h00000000);        
        run_test(32'h12345678,4,3'b111,1,32'h00000000);
        
        //====================================================
        
        if(errors==0) begin
            $display("\n======================================");
            $display("ALL %0d TESTS PASSED", test_num);
            $display("======================================");
        end
        else begin
            $display("\n======================================");
            $display("%0d / %0d TESTS FAILED", errors, test_num);
            $display("======================================");
        end
        
        $finish;
        
        end
endmodule
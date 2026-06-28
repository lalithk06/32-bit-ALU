`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_arithmetic_unit
// Description: Directed edge-case testbench for arithmetic_unit.
//              Covers: signed overflow at all 4 boundary cases (ADD/SUB/INC/DEC),
//              carry-out vs overflow distinction, sign-mismatch (no false overflow),
//              normal operation, PASS_A/PASS_B, and disabled (arith_enable=0).
//////////////////////////////////////////////////////////////////////////////////
module tb_logical_unit;

    reg  [31:0] A, B;
    reg  [2:0]  opcode;
    reg         logic_enable;

    wire [31:0] Result;
    
    integer errors;
    integer test_num;

    localparam AND    = 3'b000;
    localparam OR    = 3'b001;
    localparam NOT    = 3'b010;
    localparam XOR    = 3'b011;
    localparam NAND = 3'b100;
    localparam NOR = 3'b101;
    localparam XNOR = 3'b110;

    logical_unit DUT (
        .A(A), .B(B), .opcode(opcode), .logic_enable(logic_enable),
        .Result(Result)
    );

    task run_test;
        input [31:0] tA, tB;
        input [2:0]  top;
        input        ten;
        input [31:0] exp_result;
    
        begin
            A = tA;
            B = tB;
            opcode = top;
            logic_enable = ten;
    
            #1;
    
            test_num = test_num + 1;
    
            if(Result !== exp_result) begin
                errors = errors + 1;
                $display("FAIL [Test %0d]", test_num);
                $display("Opcode   = %b", top);
                $display("A        = %h", tA);
                $display("B        = %h", tB);
                $display("Expected = %h", exp_result);
                $display("Got      = %h", Result);
                $display("--------------------------------------");
            end
            else begin
                $display("PASS [Test %0d] op=%b A=%h B=%h -> Result=%h",
                         test_num, top, tA, tB, Result);
            end
        end
endtask

    initial begin

        errors = 0;
        test_num = 0;
        
        //============================================================
        // AND
        //============================================================
        
        run_test(32'hFFFFFFFF,32'hFFFFFFFF,AND ,1'b1,32'hFFFFFFFF);
        run_test(32'hFFFFFFFF,32'h00000000,AND ,1'b1,32'h00000000);
        run_test(32'hAAAAAAAA,32'h55555555,AND ,1'b1,32'h00000000);
        run_test(32'h12345678,32'h87654321,AND ,1'b1,32'h02244220);
        
        //============================================================
        // OR
        //============================================================
        
        run_test(32'h00000000,32'h00000000,OR,1'b1,32'h00000000);
        run_test(32'hFFFFFFFF,32'h00000000,OR,1'b1,32'hFFFFFFFF);
        run_test(32'hAAAAAAAA,32'h55555555,OR,1'b1,32'hFFFFFFFF);
        run_test(32'h12345678,32'h87654321,OR,1'b1,32'h97755779);
        
        //============================================================
        // NOT
        //============================================================
        
        run_test(32'h00000000,32'h00000000,NOT,1'b1,32'hFFFFFFFF);
        run_test(32'hFFFFFFFF,32'h00000000,NOT,1'b1,32'h00000000);
        run_test(32'hAAAAAAAA,32'h00000000,NOT,1'b1,32'h55555555);
        run_test(32'h12345678,32'h00000000,NOT,1'b1,32'hEDCBA987);
        
        //============================================================
        // XOR
        //============================================================
        
        run_test(32'hFFFFFFFF,32'hFFFFFFFF,XOR,1'b1,32'h00000000);
        run_test(32'hAAAAAAAA,32'h55555555,XOR,1'b1,32'hFFFFFFFF);
        run_test(32'h12345678,32'h87654321,XOR,1'b1,32'h95511559);
        
        //============================================================
        // NAND
        //============================================================
        
        run_test(32'hFFFFFFFF,32'hFFFFFFFF,NAND,1'b1,32'h00000000);
        run_test(32'hFFFFFFFF,32'h00000000,NAND,1'b1,32'hFFFFFFFF);
        run_test(32'hAAAAAAAA,32'h55555555,NAND,1'b1,32'hFFFFFFFF);
        
        //============================================================
        // NOR
        //============================================================
        
        run_test(32'hFFFFFFFF,32'hFFFFFFFF,NOR,1'b1,32'h00000000);
        run_test(32'h00000000,32'h00000000,NOR,1'b1,32'hFFFFFFFF);
        run_test(32'hAAAAAAAA,32'h55555555,NOR,1'b1,32'h00000000);
        
        //============================================================
        // XNOR
        //============================================================
        
        run_test(32'hFFFFFFFF,32'hFFFFFFFF,XNOR,1'b1,32'hFFFFFFFF);
        run_test(32'hAAAAAAAA,32'h55555555,XNOR,1'b1,32'h00000000);
        run_test(32'h12345678,32'h87654321,XNOR,1'b1,32'h6AAEEAA6);
        
        //============================================================
        // Disabled
        //============================================================
        
        run_test(32'hFFFFFFFF,32'hFFFFFFFF,AND ,1'b0,32'h00000000);
        run_test(32'hAAAAAAAA,32'h55555555,OR  ,1'b0,32'h00000000);
        run_test(32'h12345678,32'h87654321,XOR ,1'b0,32'h00000000);
        run_test(32'hFFFFFFFF,32'h00000000,NAND,1'b0,32'h00000000);
        run_test(32'hFFFFFFFF,32'h00000000,NOR ,1'b0,32'h00000000);
        run_test(32'hFFFFFFFF,32'h00000000,XNOR,1'b0,32'h00000000);
        run_test(32'hAAAAAAAA,32'h00000000,NOT ,1'b0,32'h00000000);
        
        //============================================================
        // Invalid opcode
        //============================================================
        
        run_test(32'h12345678,32'h87654321,3'b111,1'b1,32'h00000000);
        
        //============================================================
        
        if(errors==0) begin
            $display("\n======================================");
            $display("ALL %0d TESTS PASSED",test_num);
            $display("======================================");
        end
        else begin
            $display("\n======================================");
            $display("%0d / %0d TESTS FAILED",errors,test_num);
            $display("======================================");
        end
        
        $finish;

    end
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_arithmetic_unit
// Description: Directed edge-case testbench for arithmetic_unit.
//              Covers: signed overflow at all 4 boundary cases (ADD/SUB/INC/DEC),
//              carry-out vs overflow distinction, sign-mismatch (no false overflow),
//              normal operation, PASS_A/PASS_B, and disabled (arith_enable=0).
//////////////////////////////////////////////////////////////////////////////////
module tb_arithmetic_unit;

    reg  [31:0] A, B;
    reg  [2:0]  opcode;
    reg         arith_enable;

    wire [31:0] Result;
    wire        Cout, V;

    integer errors;
    integer test_num;

    localparam ADD    = 3'b000;
    localparam SUB    = 3'b001;
    localparam INC    = 3'b010;
    localparam DEC    = 3'b011;
    localparam PASS_A = 3'b100;
    localparam PASS_B = 3'b101;

    arithmetic_unit DUT (
        .A(A), .B(B), .opcode(opcode), .arith_enable(arith_enable),
        .Result(Result), .Cout(Cout), .V(V)
    );

    task run_test;
        input [31:0] tA, tB;
        input [2:0]  top;
        input        ten;
        input [31:0] exp_result;
        input        exp_cout;
        input        exp_v;
        begin
            A = tA; B = tB; opcode = top; arith_enable = ten;
            #10;
            test_num = test_num + 1;
            if (Result !== exp_result || Cout !== exp_cout || V !== exp_v) begin
                errors = errors + 1;
                $display("FAIL [Test %0d] op=%b A=%h B=%h en=%b -> Result=%h(exp %h) Cout=%b(exp %b) V=%b(exp %b)",
                           test_num, top, tA, tB, ten, Result, exp_result, Cout, exp_cout, V, exp_v);
            end else begin
                $display("PASS [Test %0d] op=%b A=%h B=%h -> Result=%h Cout=%b V=%b",
                           test_num, top, tA, tB, Result, Cout, V);
            end
        end
    endtask

    initial begin
    errors = 0;
    test_num = 0;

    //============================================================
    // ADD
    //============================================================

    run_test(32'd10,        32'd20,        ADD,1'b1,32'd30,        1'b0,1'b0);
    run_test(32'h7FFFFFFF,  32'h00000001,  ADD,1'b1,32'h80000000,  1'b0,1'b1);
    run_test(32'hFFFFFFFF,  32'h00000001,  ADD,1'b1,32'h00000000,  1'b1,1'b0);
    run_test(-32'd5,        -32'd3,        ADD,1'b1,-32'd8,        1'b1,1'b0);

    // New edge cases
    run_test(32'h80000000,  32'h80000000,  ADD,1'b1,32'h00000000,  1'b1,1'b1);
    run_test(32'hAAAAAAAA,  32'h55555555,  ADD,1'b1,32'hFFFFFFFF,  1'b0,1'b0);
    run_test(32'h00000000,  32'h00000000,  ADD,1'b1,32'h00000000,  1'b0,1'b0);
    run_test(32'hFFFFFFFF,  32'hFFFFFFFF,  ADD,1'b1,32'hFFFFFFFE,  1'b1,1'b0);

    //============================================================
    // SUB
    //============================================================

    run_test(32'd50,        32'd20,        SUB,1'b1,32'd30,        1'b1,1'b0);
    run_test(32'h80000000,  32'h00000001,  SUB,1'b1,32'h7FFFFFFF,  1'b1,1'b1);
    run_test(32'd5,         32'd10,        SUB,1'b1,-32'd5,        1'b0,1'b0);

    // New edge cases
    run_test(32'h7FFFFFFF,  32'hFFFFFFFF,  SUB,1'b1,32'h80000000,  1'b0,1'b1);
    run_test(32'd0,         32'd0,         SUB,1'b1,32'd0,         1'b1,1'b0);
    run_test(32'hFFFFFFFF,  32'hFFFFFFFF,  SUB,1'b1,32'd0,         1'b1,1'b0);
    run_test(32'h80000000,  32'h80000000,  SUB,1'b1,32'd0,         1'b1,1'b0);

    //============================================================
    // INC
    //============================================================

    run_test(32'd99,        32'd0,         INC,1'b1,32'd100,       1'b0,1'b0);
    run_test(32'h7FFFFFFF,  32'd0,         INC,1'b1,32'h80000000,  1'b0,1'b1);

    // New edge cases
    run_test(32'hFFFFFFFF,  32'd0,         INC,1'b1,32'h00000000,  1'b1,1'b0);
    run_test(32'd0,         32'd0,         INC,1'b1,32'd1,         1'b0,1'b0);

    //============================================================
    // DEC
    //============================================================

    run_test(32'd100,       32'd0,         DEC,1'b1,32'd99,        1'b1,1'b0);
    run_test(32'h80000000,  32'd0,         DEC,1'b1,32'h7FFFFFFF,  1'b1,1'b1);

    // New edge cases
    run_test(32'd0,         32'd0,         DEC,1'b1,32'hFFFFFFFF,  1'b0,1'b0);
    run_test(32'd1,         32'd0,         DEC,1'b1,32'd0,         1'b1,1'b0);

    //============================================================
    // PASS A
    //============================================================

    run_test(32'hDEADBEEF,32'hCAFEBABE,PASS_A,1'b1,
             32'hDEADBEEF,1'b0,1'b0);

    run_test(32'h00000000,32'hFFFFFFFF,PASS_A,1'b1,
             32'h00000000,1'b0,1'b0);

    //============================================================
    // PASS B
    //============================================================

    run_test(32'hDEADBEEF,32'hCAFEBABE,PASS_B,1'b1,
             32'hCAFEBABE,1'b0,1'b0);

    run_test(32'hFFFFFFFF,32'h00000000,PASS_B,1'b1,
             32'h00000000,1'b0,1'b0);

    //============================================================
    // Disabled mode
    //============================================================

    run_test(32'hFFFFFFFF,32'hFFFFFFFF,ADD,   1'b0,32'd0,1'b0,1'b0);
    run_test(32'h12345678,32'h87654321,SUB,   1'b0,32'd0,1'b0,1'b0);
    run_test(32'h12345678,32'd0,       INC,   1'b0,32'd0,1'b0,1'b0);
    run_test(32'h12345678,32'd0,       DEC,   1'b0,32'd0,1'b0,1'b0);
    run_test(32'h12345678,32'h87654321,PASS_A,1'b0,32'd0,1'b0,1'b0);
    run_test(32'h12345678,32'h87654321,PASS_B,1'b0,32'd0,1'b0,1'b0);

    //============================================================
    // Invalid opcodes
    //============================================================

    run_test(32'd1,32'd2,3'b110,1'b1,
             32'd0,1'b0,1'b0);

    run_test(32'd1,32'd2,3'b111,1'b1,
             32'd0,1'b0,1'b0);

    //============================================================

    if(errors==0)
    begin
        $display("\n======================================");
        $display("ALL %0d TESTS PASSED",test_num);
        $display("======================================");
    end

    if(errors!=0)
    begin
        $display("\n======================================");
        $display("%0d / %0d TESTS FAILED",errors,test_num);
        $display("======================================");
    end

    $finish;

end
endmodule
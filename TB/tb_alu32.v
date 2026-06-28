`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_alu32
// Description: Directed self-checking integration testbench for alu32.
//              Covers: arithmetic, logical, and shift operations,
//              opcode decoding, unit selection, output multiplexing,
//              status flag verification (Z, N, C, P, V),
//              invalid opcode handling, and representative
//              integration sanity checks across all functional units.
//////////////////////////////////////////////////////////////////////////////////

module tb_alu32;

    reg  [31:0] A;
    reg  [31:0] B;
    reg  [4:0]  alu_opcode;

    wire [31:0] Result;
    wire Z;
    wire N;
    wire C;
    wire P;
    wire V;

    integer errors;
    integer test_num;

    //======================================================
    // ALU OPCODES
    //======================================================

    // Arithmetic
    localparam ADD    = 5'b00000;
    localparam SUB    = 5'b00001;
    localparam INC    = 5'b00010;
    localparam DEC    = 5'b00011;
    localparam PASS_A = 5'b00100;
    localparam PASS_B = 5'b00101;

    // Logical
    localparam AND_OP  = 5'b01000;
    localparam OR_OP   = 5'b01001;
    localparam NOT_OP  = 5'b01010;
    localparam XOR_OP  = 5'b01011;
    localparam NAND_OP = 5'b01100;
    localparam NOR_OP  = 5'b01101;
    localparam XNOR_OP = 5'b01110;

    // Shift
    localparam SLL = 5'b10000;
    localparam SRL = 5'b10001;
    localparam SRA = 5'b10010;

    //======================================================
    // DUT
    //======================================================

    alu32 DUT(
        .A(A),
        .B(B),
        .alu_opcode(alu_opcode),
        .Result(Result),
        .Z(Z),
        .N(N),
        .C(C),
        .P(P),
        .V(V)
    );

    //======================================================
    // Self Checking Task
    //
    // NOTE: exp_z, exp_n, exp_p are NOT passed in anymore.
    // They are pure functions of exp_result, so we derive
    // them here instead of hand-computing (and risking typos
    // in) 32-bit popcount/sign-bit by hand for every vector.
    // Only exp_c and exp_v require real circuit knowledge
    // (carry-chain / signed-overflow semantics) that can't be
    // derived from exp_result alone -- those stay hand-supplied.
    //======================================================

    task run_test;

    input [31:0] tA;
    input [31:0] tB;
    input [4:0]  top;

    input [31:0] exp_result;
    input exp_c;
    input exp_v;

    reg exp_z, exp_n, exp_p;

    begin

        A = tA;
        B = tB;
        alu_opcode = top;

        #10;

        test_num = test_num + 1;

        exp_z = (exp_result == 32'b0);
        exp_n = exp_result[31];
        exp_p = ~^exp_result;

        if(Result!==exp_result ||
           Z!==exp_z ||
           N!==exp_n ||
           C!==exp_c ||
           P!==exp_p ||
           V!==exp_v)

        begin

            errors = errors + 1;

            $display("------------------------------------------------");

            $display("FAIL TEST %0d",test_num);

            $display("Opcode : %b",top);

            $display("A      : %h",tA);

            $display("B      : %h",tB);

            $display("Expected Result : %h",exp_result);

            $display("Got Result      : %h",Result);

            $display("Expected Z=%b N=%b C=%b P=%b V=%b",
                      exp_z,exp_n,exp_c,exp_p,exp_v);

            $display("Got      Z=%b N=%b C=%b P=%b V=%b",
                      Z,N,C,P,V);

        end

        else begin

            $display("PASS [%0d] Opcode=%b Result=%h",
                        test_num,top,Result);

        end

    end

    endtask

    //======================================================
    // TESTS
    // Call signature is now: (A, B, opcode, exp_result, exp_c, exp_v)
    //======================================================

    initial begin

        errors   = 0;
        test_num = 0;

        /////////////////////////////////////////////////////////
        // ADD
        /////////////////////////////////////////////////////////

        run_test(32'd10, 32'd20, ADD, 32'd30, 0,0);

        run_test(32'h7FFFFFFF, 32'h00000001, ADD, 32'h80000000, 0,1);

        run_test(32'hFFFFFFFF, 32'h00000001, ADD, 32'h00000000, 1,0);

        run_test(32'h80000000, 32'h80000000, ADD, 32'h00000000, 1,1);

        run_test(32'hAAAAAAAA, 32'h55555555, ADD, 32'hFFFFFFFF, 0,0);

        /////////////////////////////////////////////////////////
        // SUB
        /////////////////////////////////////////////////////////

        run_test(32'd50, 32'd20, SUB, 32'd30, 1,0);

        run_test(32'h80000000, 32'h00000001, SUB, 32'h7FFFFFFF, 1,1);

        run_test(32'd5, 32'd10, SUB, 32'hFFFFFFFB, 0,0);

        run_test(32'h7FFFFFFF, 32'hFFFFFFFF, SUB, 32'h80000000, 0,1);

        /////////////////////////////////////////////////////////
        // INC
        /////////////////////////////////////////////////////////

        run_test(32'd99, 0, INC, 32'd100, 0,0);

        run_test(32'hFFFFFFFF, 0, INC, 32'h00000000, 1,0);

        /////////////////////////////////////////////////////////
        // DEC
        /////////////////////////////////////////////////////////

        run_test(32'd100, 0, DEC, 32'd99, 1,0);

        run_test(32'd0, 0, DEC, 32'hFFFFFFFF, 0,0);

        /////////////////////////////////////////////////////////
        // PASS A
        /////////////////////////////////////////////////////////

        run_test(32'hDEADBEEF, 32'hCAFEBABE, PASS_A, 32'hDEADBEEF, 0,0);

        /////////////////////////////////////////////////////////
        // PASS B
        /////////////////////////////////////////////////////////

        run_test(32'hDEADBEEF, 32'hCAFEBABE, PASS_B, 32'hCAFEBABE, 0,0);

        /////////////////////////////////////////////////////////
        // LOGICAL : AND
        /////////////////////////////////////////////////////////

        run_test(32'hFFFFFFFF, 32'hFFFFFFFF, AND_OP, 32'hFFFFFFFF, 0,0);

        run_test(32'hFFFFFFFF, 32'h00000000, AND_OP, 32'h00000000, 0,0);

        run_test(32'hAAAAAAAA, 32'h55555555, AND_OP, 32'h00000000, 0,0);

        run_test(32'h12345678, 32'h87654321, AND_OP, 32'h02244220, 0,0);

        /////////////////////////////////////////////////////////
        // LOGICAL : OR
        /////////////////////////////////////////////////////////

        run_test(32'h00000000, 32'h00000000, OR_OP, 32'h00000000, 0,0);

        run_test(32'hFFFFFFFF, 32'h00000000, OR_OP, 32'hFFFFFFFF, 0,0);

        run_test(32'hAAAAAAAA, 32'h55555555, OR_OP, 32'hFFFFFFFF, 0,0);

        run_test(32'h12345678, 32'h87654321, OR_OP, 32'h97755779, 0,0);

        /////////////////////////////////////////////////////////
        // LOGICAL : NOT
        /////////////////////////////////////////////////////////

        run_test(32'h00000000, 0, NOT_OP, 32'hFFFFFFFF, 0,0);

        run_test(32'hFFFFFFFF, 0, NOT_OP, 32'h00000000, 0,0);

        run_test(32'hAAAAAAAA, 0, NOT_OP, 32'h55555555, 0,0);

        run_test(32'h12345678, 0, NOT_OP, 32'hEDCBA987, 0,0);

        /////////////////////////////////////////////////////////
        // LOGICAL : XOR
        /////////////////////////////////////////////////////////

        run_test(32'hFFFFFFFF, 32'hFFFFFFFF, XOR_OP, 32'h00000000, 0,0);

        run_test(32'hAAAAAAAA, 32'h55555555, XOR_OP, 32'hFFFFFFFF, 0,0);

        run_test(32'h12345678, 32'h87654321, XOR_OP, 32'h95511559, 0,0);

        /////////////////////////////////////////////////////////
        // LOGICAL : NAND
        /////////////////////////////////////////////////////////

        run_test(32'hFFFFFFFF, 32'hFFFFFFFF, NAND_OP, 32'h00000000, 0,0);

        run_test(32'hFFFFFFFF, 32'h00000000, NAND_OP, 32'hFFFFFFFF, 0,0);

        run_test(32'hAAAAAAAA, 32'h55555555, NAND_OP, 32'hFFFFFFFF, 0,0);

        /////////////////////////////////////////////////////////
        // LOGICAL : NOR
        /////////////////////////////////////////////////////////

        run_test(32'hFFFFFFFF, 32'hFFFFFFFF, NOR_OP, 32'h00000000, 0,0);

        run_test(32'h00000000, 32'h00000000, NOR_OP, 32'hFFFFFFFF, 0,0);

        run_test(32'hAAAAAAAA, 32'h55555555, NOR_OP, 32'h00000000, 0,0);

        /////////////////////////////////////////////////////////
        // LOGICAL : XNOR
        /////////////////////////////////////////////////////////

        run_test(32'hFFFFFFFF, 32'hFFFFFFFF, XNOR_OP, 32'hFFFFFFFF, 0,0);

        run_test(32'hAAAAAAAA, 32'h55555555, XNOR_OP, 32'h00000000, 0,0);

        run_test(32'h12345678, 32'h87654321, XNOR_OP, 32'h6AAEEAA6, 0,0);

        /////////////////////////////////////////////////////////
        // SHIFT : SLL
        /////////////////////////////////////////////////////////

        run_test(32'h00000001, 32'd1, SLL, 32'h00000002, 0,0);

        run_test(32'h00000001, 32'd31, SLL, 32'h80000000, 0,0);

        run_test(32'hAAAAAAAA, 32'd4, SLL, 32'hAAAAAAA0, 0,0);

        /////////////////////////////////////////////////////////
        // SHIFT : SRL
        /////////////////////////////////////////////////////////

        run_test(32'h80000000, 32'd1, SRL, 32'h40000000, 0,0);

        run_test(32'hFFFFFFFF, 32'd1, SRL, 32'h7FFFFFFF, 0,0);

        run_test(32'h12345678, 32'd4, SRL, 32'h01234567, 0,0);

        /////////////////////////////////////////////////////////
        // SHIFT : SRA
        /////////////////////////////////////////////////////////

        run_test(32'h80000000, 32'd1, SRA, 32'hC0000000, 0,0);

        run_test(32'hFFFFFFFF, 32'd1, SRA, 32'hFFFFFFFF, 0,0);

        run_test(32'h80000000, 32'd31, SRA, 32'hFFFFFFFF, 0,0);

        /////////////////////////////////////////////////////////
        // INVALID ALU OPCODES (11xxx)
        /////////////////////////////////////////////////////////

        run_test(32'h12345678, 32'h87654321, 5'b11000, 32'h00000000, 0,0);

        run_test(32'hAAAAAAAA, 32'h55555555, 5'b11111, 32'h00000000, 0,0);

        /////////////////////////////////////////////////////////
        // Integration sanity checks
        /////////////////////////////////////////////////////////

        run_test(32'hAAAAAAAA, 32'h55555555, ADD, 32'hFFFFFFFF, 0,0);

        run_test(32'hAAAAAAAA, 32'h55555555, AND_OP, 32'h00000000, 0,0);

        run_test(32'hAAAAAAAA, 32'h55555555, OR_OP, 32'hFFFFFFFF, 0,0);

        run_test(32'hAAAAAAAA, 32'd4, SLL, 32'hAAAAAAA0, 0,0);

        /////////////////////////////////////////////////////////
        // SUMMARY
        /////////////////////////////////////////////////////////

        if(errors==0)
        begin
            $display("");
            $display("======================================");
            $display("ALL %0d ALU TESTS PASSED", test_num);
            $display("======================================");
        end
        else
        begin
            $display("");
            $display("======================================");
            $display("%0d / %0d ALU TESTS FAILED", errors, test_num);
            $display("======================================");
        end

        $finish;

    end

endmodule
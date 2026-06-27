`timescale 1ns / 1ps

module tb_cla32;

    reg  [31:0] A, B;
    reg         Cin;
    wire [31:0] S;
    wire        Cout;

    reg  [32:0] expected;

    integer errors;
    integer i;

    // DUT
    cla32 DUT (
        .A(A),
        .B(B),
        .Cin(Cin),
        .S(S),
        .Cout(Cout)
    );

    initial begin

        errors = 0;

        //--------------------------------------------------
        // Directed Test Cases
        //--------------------------------------------------

        check(32'h00000000, 32'h00000000, 1'b0);
        check(32'h00000000, 32'h00000001, 1'b0);
        check(32'h00000001, 32'h00000001, 1'b0);

        check(32'hFFFFFFFF, 32'h00000001, 1'b0);
        check(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b0);

        check(32'h7FFFFFFF, 32'h00000001, 1'b0);
        check(32'h80000000, 32'h80000000, 1'b0);

        check(32'hAAAAAAAA, 32'h55555555, 1'b0);
        check(32'h12345678, 32'h87654321, 1'b0);

        check(32'hFFFFFFFF, 32'h00000000, 1'b1);
        check(32'h00000000, 32'h00000000, 1'b1);

        //--------------------------------------------------
        // Random Tests
        //--------------------------------------------------

        for(i = 0; i < 100000; i = i + 1) begin

            A   = $random;
            B   = $random;
            Cin = $random & 1;

            expected = A + B + Cin;

            #1;

            if({Cout,S} !== expected) begin
                errors = errors + 1;
                $display("FAIL:");
                $display("A=%h B=%h Cin=%b",A,B,Cin);
                $display("Expected=%h Got=%h",
                          expected,{Cout,S});
            end

        end

        //--------------------------------------------------

        if(errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d TESTS FAILED",errors);

        $finish;

    end

    //------------------------------------------------------
    // Task
    //------------------------------------------------------

    task check;

        input [31:0] a;
        input [31:0] b;
        input        cin;

        begin

            A   = a;
            B   = b;
            Cin = cin;

            expected = a + b + cin;

            #1;

            if({Cout,S} !== expected) begin

                errors = errors + 1;

                $display("FAIL:");
                $display("A=%h B=%h Cin=%b",a,b,cin);
                $display("Expected=%h Got=%h",
                          expected,{Cout,S});

            end

        end

    endtask

endmodule
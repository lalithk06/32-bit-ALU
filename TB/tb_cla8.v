`timescale 1ns / 1ps

module tb_cla8;
    reg  [7:0] A, B;
    reg        Cin;
    wire [7:0] S;
    wire       Cout;
    reg  [8:0] expected;

    integer errors;

    cla8 DUT(
            .A(A), 
            .B(B),  
            .Cin(Cin), 
            .S(S), 
            .Cout(Cout)
            );

    integer i, j, k;

    initial begin
        errors = 0;
    
        for (i = 0; i < 256; i = i + 1) begin
            for (j = 0; j < 256; j = j + 1) begin
                for (k = 0; k < 2; k = k + 1) begin
    
                    A   = i;
                    B   = j;
                    Cin = k;
    
                    expected = A + B + Cin;
    
                    #5;
    
                    if ({Cout, S} !== expected) begin
                        errors = errors + 1;
                        $display("FAIL: A=%h B=%h Cin=%b Expected=%h Got=%h",
                                  A, B, Cin, expected, {Cout,S});
                    end
    
                end
            end
        end
    
        if (errors == 0)
            $display("ALL 131,072 TESTS PASSED");
        else
            $display("%0d FAILURES", errors);
    
        $finish;
    end
endmodule
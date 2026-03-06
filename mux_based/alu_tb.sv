`timescale 1ns / 1ps

module alu_mux_tb();
    // Inputs
    logic        clk;
    logic        reset;
    logic [3:0]  operator; // MUX-based uses 4-bit operator
    logic [7:0]  A;
    logic [7:0]  B;
    logic        c_i;      // External carry-in

    // Outputs
    logic [7:0]  Z;
    logic        c_o;      // Carry out
    logic        b_o;      // Borrow out

    // Instantiate the MUX-based ALU (Unit Under Test)
    alu uut (
        .clk(clk),
        .rst(reset),        // Mapped to rst
        .operand1(A),       // Mapped to operand1
        .operand2(B),       // Mapped to operand2
        .c_i(c_i),
        .operator(operator),
        .c_o(c_o),
        .b_o(b_o),
        .finalOutput(Z)     // Mapped to Z
    );

    // Clock generation
    always #5 clk = ~clk;

    // --- MUX-based ALU Opcode Definitions ---
    localparam OP_ADD  = 4'b0000;
    localparam OP_ADDC = 4'b0001;
    localparam OP_SUB  = 4'b0010; // A - B
    localparam OP_SUBR = 4'b0011; // B - A
    localparam OP_XOR  = 4'b0100;
    localparam OP_XNOR = 4'b0101;

    // Task to apply vectors and check result (Unsigned)
    task apply_and_check_unsigned(
        input string op_name,
        input [3:0]  op_code,
        input [7:0]  a_val,
        input [7:0]  b_val,
        input        ci_val
    );
        begin
            operator = op_code; A = a_val; B = b_val; c_i = ci_val;
            @(posedge clk); 
            #1; // Wait for sequential logic update
            $display("[%4s] A:%4d B:%4d CI:%b | Z:%4d (Hex:%h) Carry:%b", 
                     op_name, A, B, c_i, Z, Z, c_o);
        end
    endtask

    // Task to apply vectors and check result (Signed/Subtraction)
    task apply_and_check_signed(
        input string op_name,
        input [3:0]  op_code,
        input [7:0]  a_val,
        input [7:0]  b_val,
        input        ci_val
    );
        begin
            operator = op_code; A = a_val; B = b_val; c_i = ci_val;
            @(posedge clk); 
            #1; 
            // NOTE: In MUX direct subtraction, b_o == 1 means negative (borrow)
            $display("[%4s] A:%4d B:%4d | Z:%4d (Hex:%h) Borrow:%b %s", 
                     op_name, A, B, $signed(Z), Z, b_o, 
                     b_o == 1 ? "<-- Negative result (Borrow)" : "");
        end
    endtask
    
    // Task to apply vectors and check result (Binary/Logic)
    task apply_and_check_binary(
        input string op_name,
        input [3:0]  op_code,
        input [7:0]  a_val,
        input [7:0]  b_val,
        input        ci_val
    );
        begin
            operator = op_code; A = a_val; B = b_val; c_i = ci_val;
            @(posedge clk); 
            #1; 
            $display("[%4s] A:%b B:%b | Z:%b (Hex:%h)", 
                     op_name, A, B, Z, Z);
        end
    endtask

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        operator = 0; A = 0; B = 0; c_i = 0;

        #15 reset = 0;
        $display("--- Starting MUX-based ALU Tests ---");

        // 1. Test ADD (A + B)
        $display("\n--- Testing ADD ---");
        apply_and_check_unsigned("ADD", OP_ADD, 8'd5,   8'd10,  1'b0); // 15
        apply_and_check_unsigned("ADD", OP_ADD, 8'd255, 8'd1,   1'b0); // 0, Carry=1

        // 2. Test ADDC (A + B + CI)
        $display("\n--- Testing ADDC ---");
        apply_and_check_unsigned("ADDC", OP_ADDC, 8'd5,  8'd10, 1'b1); // 16
        apply_and_check_unsigned("ADDC", OP_ADDC, 8'd127,8'd127,1'b1); // 255

        // 3. Test SUB (A - B) 
        $display("\n--- Testing SUB (A - B) ---");
        apply_and_check_signed("SUB", OP_SUB, 8'd10, 8'd5,  1'b0); // 10-5 = 5, B=0
        apply_and_check_signed("SUB", OP_SUB, 8'd5,  8'd10, 1'b0); // 5-10 = -5, B=1
        apply_and_check_signed("SUB", OP_SUB, 8'd0,  8'd1,  1'b0); // 0-1 = -1, B=1

        // 4. Test SUBR (B - A)
        $display("\n--- Testing SUBR (B - A) ---");
        apply_and_check_signed("SUBR", OP_SUBR, 8'd5,  8'd10, 1'b0); // 10-5 = 5, B=0
        apply_and_check_signed("SUBR", OP_SUBR, 8'd20, 8'd5,  1'b0); // 5-20 = -15, B=1

        // 5. Test Logic Operations
        $display("\n--- Testing Logic (XOR/XNOR) ---");
        apply_and_check_binary("XOR",  OP_XOR,  8'hAA, 8'h55, 1'b0); // FF
        apply_and_check_binary("XNOR", OP_XNOR, 8'hAA, 8'h55, 1'b0); // 00

        #20 $finish;
    end

endmodule

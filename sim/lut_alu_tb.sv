`timescale 1ns / 1ps

module lut_alu_tb();
// Inputs
    logic        clk;
    logic        reset;
    logic [9:0]  opcode;
    logic [7:0]  A;
    logic [7:0]  B;
    logic        CI;

    // Outputs
    logic [7:0]  Z;
    logic        CO;

    // Instantiate the Unit Under Test (UUT)
    lut_alu uut (
        .clk(clk),
        .reset(reset),
        .opcode(opcode),
        .A(A),
        .B(B),
        .CI(CI),
        .Z(Z),
        .CO(CO)
    );

    // Clock generation
    always #5 clk = ~clk;

    // --- Updated Opcodes based on [9:8] Ci, [7:4] G, [3:0] P mapping ---
    localparam OP_ADD  = 10'b00_0001_0110; 
    localparam OP_ADDC = 10'b10_0001_0110; 
    localparam OP_SUB  = 10'b01_0010_1001; // A - B (G=A&~B, P=XNOR, Ci=1)
    localparam OP_SUBR = 10'b01_0100_1001; // B - A (G=~A&B, P=XNOR, Ci=1)
    localparam OP_XOR  = 10'b00_0000_0110; 
    localparam OP_XNOR = 10'b00_0000_1001;

    // Task to apply vectors and check result
    task apply_and_check_unsigned(
        input string op_name,
        input [9:0]  op_code,
        input [7:0]  a_val,
        input [7:0]  b_val,
        input        ci_val
    );
        begin
            opcode = op_code; A = a_val; B = b_val; CI = ci_val;
            @(posedge clk); 
            #1; // wait for Sequential logic (z_d -> Z)
            $display("[%4s] A:%4d B:%4d CI:%b | Z:%4d (Hex:%h) CO:%b ", 
                     op_name, A, B, CI, Z, Z, CO);
        end
    endtask
    task apply_and_check_signed(
        input string op_name,
        input [9:0]  op_code,
        input [7:0]  a_val,
        input [7:0]  b_val,
        input        ci_val
    );
        begin
            opcode = op_code; A = a_val; B = b_val; CI = ci_val;
            @(posedge clk); 
            #1; // wait for Sequential logic (z_d -> Z)
            $display("[%4s] A:%4d B:%4d  CI:%b | Z:%4d (Hex:%h) CO:%b %s", 
                     op_name, A, B, CI, $signed(Z), Z, CO, 
                     CO == 0 ? "<-- Negative result (Borrow)" : "");
        end
    endtask
    
    task apply_and_check_binary(
        input string op_name,
        input [9:0]  op_code,
        input [7:0]  a_val,
        input [7:0]  b_val,
        input        ci_val
    );
        begin
            opcode = op_code; A = a_val; B = b_val; CI = ci_val;
            @(posedge clk); 
            #1; // wait for Sequential logic (z_d -> Z)
            $display("[%4s] A:%b B:%b CI:%b | Z:%b (Hex:%h) CO:%b", 
                     op_name, A, B, CI, Z, Z, CO);
        end
    endtask
    


    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        opcode = 0; A = 0; B = 0; CI = 0;

        #15 reset = 0;
        $display("--- Starting ALU Tests (Updated Mapping) ---");

        // 1. Test ADD (A + B)
        $display("\n--- Testing ADD ---");
        apply_and_check_unsigned("ADD", OP_ADD, 8'd5,   8'd10,  1'b0); // 15
        apply_and_check_unsigned("ADD", OP_ADD, 8'd255, 8'd1,   1'b0); // 0, CO=1

        // 2. Test ADDC (A + B + CI)
        $display("\n--- Testing ADDC ---");
        apply_and_check_unsigned("ADDC", OP_ADDC, 8'd5,  8'd10, 1'b1); // 16
        apply_and_check_unsigned("ADDC", OP_ADDC, 8'd127,8'd127,1'b1); // 255

        // 3. Test SUB (A - B) 
        $display("\n--- Testing SUB (A - B) ---");
        apply_and_check_signed("SUB", OP_SUB, 8'd10, 8'd5,  1'b0); // 10-5 = 5, CO=1 (No borrow)
        apply_and_check_signed("SUB", OP_SUB, 8'd5,  8'd10, 1'b0); // 5-10 = 251, CO=0 (Borrow)
        apply_and_check_signed("SUB", OP_SUB, 8'd100,8'd100,1'b0); // 100-100 = 0, CO=1
        apply_and_check_signed("SUB", OP_SUB, 8'd0,  8'd1,  1'b0); // 0-1 = 255, CO=0

        // 4. Test SUBR (B - A)
        $display("\n--- Testing SUBR (B - A) ---");
        apply_and_check_signed("SUBR", OP_SUBR, 8'd5,  8'd10, 1'b0); // 10-5 = 5, CO=1
        apply_and_check_signed("SUBR", OP_SUBR, 8'd10, 8'd5,  1'b0); // 5-10 = 251, CO=0

        // 5. Test Logic Operations
        $display("\n--- Testing Logic (XOR/XNOR) ---");
        apply_and_check_binary("XOR",  OP_XOR,  8'hAA, 8'h55, 1'b0); // FF
        apply_and_check_binary("XNOR", OP_XNOR, 8'hAA, 8'h55, 1'b0); // 00

        #20 $finish;
    end

endmodule

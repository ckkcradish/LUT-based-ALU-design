# LUT-based-ALU-design
A LUT-based ALU design using Systemverilog. For SJSU IEEE Digital Workshop of ALU design.

src/lut_alu.sv : The lut-based alu design code.
sim/lut_alu_tb : The testbench.

Simulation Result (TCL Log):

--- Starting ALU Tests (Updated Mapping) ---

--- Testing ADD ---
[ ADD] A:   5 B:  10 CI:0 | Z:  15 (Hex:0f) CO:0 
[ ADD] A: 255 B:   1 CI:0 | Z:   0 (Hex:00) CO:1 

--- Testing ADDC ---
[ADDC] A:   5 B:  10 CI:1 | Z:  16 (Hex:10) CO:0 
[ADDC] A: 127 B: 127 CI:1 | Z: 255 (Hex:ff) CO:0 

--- Testing SUB (A - B) ---
[ SUB] A:  10 B:   5  CI:0 | Z:   5 (Hex:05) CO:1                             
[ SUB] A:   5 B:  10  CI:0 | Z:  -5 (Hex:fb) CO:0 <-- Negative result (Borrow)
[ SUB] A: 100 B: 100  CI:0 | Z:   0 (Hex:00) CO:1                             
[ SUB] A:   0 B:   1  CI:0 | Z:  -1 (Hex:ff) CO:0 <-- Negative result (Borrow)

--- Testing SUBR (B - A) ---
[SUBR] A:   5 B:  10  CI:0 | Z:   5 (Hex:05) CO:1                             
[SUBR] A:  10 B:   5  CI:0 | Z:  -5 (Hex:fb) CO:0 <-- Negative result (Borrow)

--- Testing Logic (XOR/XNOR) ---
[ XOR] A:10101010 B:01010101 CI:0 | Z:11111111 (Hex:ff) CO:0
[XNOR] A:10101010 B:01010101 CI:0 | Z:00000000 (Hex:00) CO:0
$finish called at time : 146 ns

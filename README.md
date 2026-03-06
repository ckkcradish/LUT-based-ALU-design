# LUT-based-ALU-design
A LUT-based ALU design using Systemverilog. For SJSU IEEE Digital Workshop of ALU design.

src/lut_alu.sv : The lut-based alu design code. <br>
sim/lut_alu_tb : The testbench.

Simulation Result (TCL Log):

--- Starting ALU Tests (Updated Mapping) --- <br>

--- Testing ADD --- <br>
[ ADD] A:   5 B:  10 CI:0 | Z:  15 (Hex:0f) CO:0 <br>
[ ADD] A: 255 B:   1 CI:0 | Z:   0 (Hex:00) CO:1 <br>

--- Testing ADDC --- <br>
[ADDC] A:   5 B:  10 CI:1 | Z:  16 (Hex:10) CO:0 <br>
[ADDC] A: 127 B: 127 CI:1 | Z: 255 (Hex:ff) CO:0 <br>

--- Testing SUB (A - B) --- <br>
[ SUB] A:  10 B:   5  CI:0 | Z:   5 (Hex:05) CO:1 <br>                             
[ SUB] A:   5 B:  10  CI:0 | Z:  -5 (Hex:fb) CO:0 <-- Negative result (Borrow) <br>
[ SUB] A: 100 B: 100  CI:0 | Z:   0 (Hex:00) CO:1 <br>                             
[ SUB] A:   0 B:   1  CI:0 | Z:  -1 (Hex:ff) CO:0 <-- Negative result (Borrow) <br>

--- Testing SUBR (B - A) --- <br>
[SUBR] A:   5 B:  10  CI:0 | Z:   5 (Hex:05) CO:1 <br>
[SUBR] A:  10 B:   5  CI:0 | Z:  -5 (Hex:fb) CO:0 <-- Negative result (Borrow) <br>

--- Testing Logic (XOR/XNOR) --- <br>
[ XOR] A:10101010 B:01010101 CI:0 | Z:11111111 (Hex:ff) CO:0 <br>
[XNOR] A:10101010 B:01010101 CI:0 | Z:00000000 (Hex:00) CO:0 <br>


$finish called at time : 146 ns

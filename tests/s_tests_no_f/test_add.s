# Load test operands
li  a0, 1
li  a1, 2
# Test of addition
nop
nop
nop
add a3, a0, a1 # Expected value is 3
nop
nop
nop
# Test of addition
nop
nop
nop
add a2, a0, a1 # Expected value is 3
nop
nop
nop
nop
add a4, a1, a2 # Expected value is 5
nop
nop
nop
# Test of addition
nop
nop
nop
add a2, a0, a0 # Expected value is 2
nop
nop
nop
nop
add a5, a0, a2 # Expected value is 3
nop
nop
nop
# Test of addition
nop
nop
nop
add a2, a1, a1 # Expected value is 4
nop
nop
nop
nop
add a6, a2, a0 # Expected value is 5
nop
nop
nop
nop
add a7, a6, a2 # Expected value is 9
nop
nop
nop
ecall

# Load test operands
li a0, 0x0102030405060708
li a1, 0x1
# Test simple addition of the two operands
nop
nop
nop
add a2, a0, a1 # Expected result is 0x0102030405060709
nop
nop
nop
ecall
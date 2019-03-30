# Load test operands
li a0, 0xA
# Test code that skips past instructions
nop
nop
nop
srli a0, a0, 4 # Expected result 0x0000000000000000
beq a0, x0, skip
addi a0, x0, 1 # This instruction should be flushed
add a0, a0, a0
nop
nop
nop
# Skips to here
skip:
addi a0, a0, 3 # Expected result 0x0000000000000003
nop
nop
nop
ecall
# Load test operands
li a0, 0x0102030405060708
# Perform jump to specific code location
nop
nop
nop
jal main
add a0, a0, a0 # Must not be performed
add a0, a0, a0 # Must not be performed
jal end
nop
nop
# Jump to here
main:
add a1, x0, a0 # Expected result 0x0102030405060708
addi ra, ra, 8
jalr ra
add a0, a0, a0 # Must not be performed
add a0, a0, a0 # Must not be performed
nop
nop
nop
# Jump to here
end:
add a2, a0, a0 # Expected result 0x020406080A0C0E10
nop
nop
nop
ecall
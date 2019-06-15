# Load test operands
li a0, 0x0102030405060708
li sp, 0x800
# Run tests including WAR hazards
nop
nop
nop
addi sp, sp, -16 # Make room on stack for two doublewords
sd a0, 0(sp) # Store doubleword
nop
nop
nop
ld a1, 0(sp) # Read doubleword (Expected result 0x0102030405060708)
sd a1, 8(sp) # Store doubleword immediately (hazard) (Expected memory content 0x0102030405060708)
nop
nop
nop
ld a2, 8(sp) # Expected result 0x0102030405060708
nop
nop
nop
addi sp, sp, 16 # Restore stack pointer
nop
nop
nop

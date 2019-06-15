# Load test operands
li a0, 0x0102030405060708
li sp, 0x800
# Run tests including RAW hazards
nop
nop
nop
addi sp, sp, -8 # Make room on stack for doubleword
sd a0, 0(sp) # Store doubleword
ld a1, 0(sp) # Read doubleword immediately (hazard) (Expected result 0x0102030405060708)
add a2, a1, a1 # Test load-use hazard detection as well (Expected result 0x020406080A0C0E10
addi sp, sp, 8 # Restore stack pointer
nop
nop
nop

# Load test operands
li a0, 0x0102030405060708
li sp, 0x800
# Run tests of storing and loading values to memory
nop
nop
nop
addi sp, sp, -8 # Make room on stack for doubleword
sd a0, 0(sp)
nop
nop
nop
# Read data out and work on it
ld a1, 0(sp) # Expected result 0x0102030405060708
add a1, a1, a0 # Expected result 0x020406080A0C0E10 (hazard)
xori a1, a1, 0x10 # Expected result 0x020406080A0C0E00
sw a1, 0(sp) # Expected memory content 0x010203040A0C0E00 (forwarding)
nop
nop
nop
# Read data out once again
ld a2, 0(sp) # Expected result 0x010203040A0C0E00
lb a3, 1(sp) # Expected result 0x000000000000000E
ori a3, a3, 0xF0 # Expected result 0x00000000000000FE
sb a3, 0(sp) # Expected result 0x010203040A0C0EFE
nop
nop
nop
# Read data out once again
ld a4, 0(sp) # Expected result 0x010203040A0C0EFE
nop
andi a5, a4, 0xF0 # Expected result 0x00000000000000F0
addi sp, sp, 8 # Restore stack pointer
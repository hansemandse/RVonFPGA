# Load test operands a0 is 0x0102030405060708
lui a0, 0x408
nop
nop
nop
nop
addiw a0, a0, 0xC1
nop
nop
nop
nop
slli a0, a0, 0x11
nop
nop
nop
nop
addi a0, a0, 0x283
nop
nop
nop
nop
slli a0, a0, 0x11
nop
nop
nop
nop
addi a0, a0, 0x708
# sp is 0x800
lui sp, 0x1
nop
nop
nop
nop
addiw sp, sp, -0x800
nop
nop
nop
# Run tests of storing and loading values to memory
nop
nop
nop
addi sp, sp, -8 # Make room on stack for doubleword
nop
nop
nop
nop
sd a0, 0(sp)
nop
nop
nop
# Read data out and work on it
ld a1, 0(sp) # Expected result 0x0102030405060708
nop
nop
nop
nop
add a1, a1, a0 # Expected result 0x020406080A0C0E10
nop
nop
nop
nop
xori a1, a1, 0x10 # Expected result 0x020406080A0C0E00
nop
nop
nop
nop
sw a1, 0(sp) # Expected memory content 0x010203040A0C0E00
nop
nop
nop
# Read data out once again
ld a2, 0(sp) # Expected result 0x010203040A0C0E00
lb a3, 1(sp) # Expected result 0x000000000000000E
nop
nop
nop
nop
ori a3, a3, 0xF0 # Expected result 0x00000000000000FE
nop
nop
nop
nop
sb a3, 0(sp) # Expected memory content 0x010203040A0C0EFE
nop
nop
nop
# Read data out once again
ld a4, 0(sp) # Expected result 0x010203040A0C0EFE
nop
nop
nop
nop
andi a5, a4, 0xF0 # Expected result 0x00000000000000F0
nop
nop
nop
# Read data out once again
ld a6, 0(sp)
nop
nop
nop
nop
srli a6, a6, 32 # Expected result 0x0000000001020304
addi sp, sp, 8 # Restore stack pointer
nop
nop
nop
ecall

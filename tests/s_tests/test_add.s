# Load test operands
li  a0, 0x0123456789ABCDEF
li  a1, 1
# Test of addition (no forwarding)
nop
nop
nop
add a3, a0, a1 # Expected value is 0x0123456789ABCDF0
nop
nop
nop
# Test of addition (forwarding from EX)
nop
nop
nop
add a2, a0, a1 # Expected value is 0x0123456789ABCDF0
add a4, a1, a2 # Expected value is 0x0123456789ABCDF1
nop
nop
nop
# Test of addition (forwarding from MEM)
nop
nop
nop
add a2, a0, a0 # Expected value is 0x02468ACF13579BDE
nop
add a5, a0, a2 # Expected value is 0x0369D0369D0369CD
nop
nop
nop
# Test of addition (forwarding from EX and MEM)
nop
nop
nop
add a2, a1, a1 # Expected value is 0x0000000000000002
add a6, a2, a0 # Expected value is 0x0123456789ABCDF1
add a7, a6, a2 # Expected value is 0x0123456789ABCDF3
nop
nop
nop
ecall
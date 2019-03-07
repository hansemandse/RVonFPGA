# Load test operands
li  a0, 0x0123456789ABCDEF
li  a1, 1
# Test of addition (no forwarding)
nop
nop
nop
add a2, a0, a1 # Expected value is 0x0123456789ABCDF0
nop
nop
nop
# Test of addition (forwarding from EX)
nop
nop
nop
add a2, a0, a1 # Expected value is 0x0123456789ABCDF0
add a3, a1, a2 # Expected value is 0x0123456789ABCDF1
nop
nop
nop
# Test of addition (forwarding from MEM)
nop
nop
nop
add a2, a0, a1 # Expected value is 0x0123456789ABCDF0
nop
add a3, a0, a2 # Expected value is 0x013579BE02468ACE
nop
nop
nop
# Test of addition (forwarding from EX and MEM)
nop
nop
nop
add a2, a0, a0 # Expected value is 0x02468ACF13579BDE
add a3, a1, a1 # Expected value is 0x0000000000000002
add a4, a2, a3 # Expected value is 0x02468ACF13579BE0
nop
nop
nop
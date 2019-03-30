	.file	"jump.c"
	.option nopic
	.text
 #APP
	li sp, 0x800
	j main
	ecall
 #NO_APP
	.align	2
	.globl	add
	.type	add, @function
add:
	addi	sp,sp,-32
	sd	s0,24(sp)
	addi	s0,sp,32
	sd	a0,-24(s0)
	sd	a1,-32(s0)
	ld	a4,-24(s0)
	ld	a5,-32(s0)
	add	a5,a4,a5
	mv	a0,a5
	ld	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	add, .-add
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-48
	sd	ra,40(sp)
	sd	s0,32(sp)
	addi	s0,sp,48
	li	a5,7614464
	addi	a5,a5,-1191
	sd	a5,-24(s0)
	li	a5,82161664
	addi	a5,a5,1074
	sd	a5,-32(s0)
	ld	a1,-32(s0)
	ld	a0,-24(s0)
	call	add
	sd	a0,-40(s0)
	li	a5,0
	mv	a0,a5
	ld	ra,40(sp)
	ld	s0,32(sp)
	addi	sp,sp,48
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 8.2.0"

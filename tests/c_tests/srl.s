	.file	"srl.c"
	.option nopic
	.text
 #APP
	li sp, 0x800
	j main
	ecall
 #NO_APP
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-48
	sd	s0,40(sp)
	addi	s0,sp,48
	li	a5,12840960
	addi	a5,a5,338
	sd	a5,-24(s0)
	li	a5,11
	sd	a5,-32(s0)
	ld	a5,-24(s0)
	ld	a4,-32(s0)
	sext.w	a4,a4
	srl	a5,a5,a4
	sd	a5,-40(s0)
	li	a5,0
	mv	a0,a5
	ld	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 8.2.0"

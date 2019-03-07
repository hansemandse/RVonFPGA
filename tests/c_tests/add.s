	.file	"add.c"
	.option nopic
	.text
 #APP
	li sp, 0x800
	j main
 #NO_APP
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-48
	sd	s0,40(sp)
	addi	s0,sp,48
	li	a5,115
	sd	a5,-24(s0)
	li	a5,8192
	addi	a5,a5,-1050
	sd	a5,-32(s0)
	ld	a4,-24(s0)
	ld	a5,-32(s0)
	add	a5,a4,a5
	sd	a5,-40(s0)
	li	a5,0
	mv	a0,a5
	ld	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 8.2.0"

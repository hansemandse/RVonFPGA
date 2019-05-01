	.file	"test.c"
	.option nopic
	.text
 #APP
	j main
 #NO_APP
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	sd	ra,24(sp)
	sd	s0,16(sp)
	addi	s0,sp,32
	li	a5,1
	sd	a5,-24(s0)
	ld	a1,-24(s0)
	ld	a0,-32(s0)
	call	foo
	sd	a0,-32(s0)
	li	a5,0
	mv	a0,a5
	ld	ra,24(sp)
	ld	s0,16(sp)
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.align	2
	.globl	foo
	.type	foo, @function
foo:
	addi	sp,sp,-48
	sd	s0,40(sp)
	addi	s0,sp,48
	sd	a0,-40(s0)
	sd	a1,-48(s0)
	sd	zero,-24(s0)
	sw	zero,-28(s0)
	j	.L4
.L5:
	ld	a4,-40(s0)
	ld	a5,-48(s0)
	add	a5,a4,a5
	ld	a4,-24(s0)
	add	a5,a4,a5
	sd	a5,-24(s0)
	lw	a5,-28(s0)
	sext.w	a5,a5
	addiw	a5,a5,1
	sext.w	a5,a5
	sw	a5,-28(s0)
.L4:
	lw	a5,-28(s0)
	sext.w	a5,a5
	mv	a4,a5
	li	a5,99
	ble	a4,a5,.L5
	ld	a5,-24(s0)
	mv	a0,a5
	ld	s0,40(sp)
	addi	sp,sp,48
	jr	ra
	.size	foo, .-foo
	.ident	"GCC: (GNU) 8.2.0"

	.file	"test.c"
	.option nopic
	.text
	.align	2
	.globl	sum1
	.type	sum1, @function
sum1:
	mv	a6,a0
	blez	a1,.L9
	sext.w	a7,a1
	neg	a4,a0
	addiw	a3,a7,-1
	li	a5,16
	andi	a4,a4,7
	bleu	a3,a5,.L10
	beqz	a4,.L11
	li	a5,1
	lbu	t6,0(a0)
	beq	a4,a5,.L12
	lbu	a5,1(a0)
	li	a3,2
	addw	t6,a5,t6
	andi	t6,t6,0xff
	beq	a4,a3,.L13
	lbu	a5,2(a0)
	li	a3,3
	addw	t6,a5,t6
	andi	t6,t6,0xff
	beq	a4,a3,.L14
	lbu	a5,3(a0)
	li	a3,4
	addw	t6,a5,t6
	andi	t6,t6,0xff
	beq	a4,a3,.L15
	lbu	a5,4(a0)
	li	a3,5
	addw	t6,a5,t6
	andi	t6,t6,0xff
	beq	a4,a3,.L16
	lbu	a5,5(a0)
	li	a3,7
	addw	t6,a5,t6
	andi	t6,t6,0xff
	bne	a4,a3,.L17
	lbu	a5,6(a0)
	li	t1,7
	addw	t6,a5,t6
	andi	t6,t6,0xff
.L4:
	subw	a7,a7,a4
	lui	a5,%hi(.LC0)
	srliw	t3,a7,3
	ld	a0,%lo(.LC0)(a5)
	add	a4,a6,a4
	lui	a5,%hi(.LC1)
	slli	t3,t3,3
	ld	t5,%lo(.LC1)(a5)
	sext.w	t4,a7
	add	t3,t3,a4
	li	a5,0
.L6:
	ld	a3,0(a4)
	and	a2,a5,a0
	addi	a4,a4,8
	xor	a5,a5,a3
	and	a3,a3,a0
	add	a3,a2,a3
	and	a5,a5,t5
	xor	a5,a3,a5
	bne	a4,t3,.L6
	srli	a4,a5,8
	addw	a4,a5,a4
	srli	a3,a5,16
	addw	a4,a4,t6
	addw	a4,a4,a3
	srli	a3,a5,24
	addw	a4,a4,a3
	srli	a3,a5,32
	addw	a4,a4,a3
	srli	a3,a5,40
	srli	a0,a5,48
	addw	a4,a4,a3
	addw	a4,a4,a0
	srli	a5,a5,56
	andi	a7,a7,-8
	addw	a5,a4,a5
	sext.w	a7,a7
	andi	a0,a5,0xff
	addw	t1,a7,t1
	beq	t4,a7,.L20
.L3:
	add	a5,a6,t1
	lbu	a5,0(a5)
	addiw	a3,t1,1
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a3,.L2
	add	a3,a6,a3
	lbu	a5,0(a3)
	addiw	a4,t1,2
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,3
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,4
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,5
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,6
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,7
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,8
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,9
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,10
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,11
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,12
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,13
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,14
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,15
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a4,a6,a4
	lbu	a5,0(a4)
	addiw	a4,t1,16
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ble	a1,a4,.L2
	add	a6,a6,a4
	lbu	a5,0(a6)
	addw	a5,a5,a0
	andi	a0,a5,0xff
	ret
.L9:
	li	a0,0
.L2:
	ret
.L14:
	li	t1,3
	j	.L4
.L20:
	ret
.L11:
	li	t1,0
	li	t6,0
	j	.L4
.L12:
	li	t1,1
	j	.L4
.L10:
	li	t1,0
	li	a0,0
	j	.L3
.L13:
	li	t1,2
	j	.L4
.L15:
	li	t1,4
	j	.L4
.L16:
	li	t1,5
	j	.L4
.L17:
	li	t1,6
	j	.L4
	.size	sum1, .-sum1
	.align	2
	.globl	sum2
	.type	sum2, @function
sum2:
	blez	a1,.L24
	addiw	a1,a1,-1
	slli	a1,a1,32
	addi	a3,a0,2
	srli	a4,a1,31
	mv	a5,a0
	add	a4,a4,a3
	li	a0,0
.L23:
	lhu	a3,0(a5)
	addi	a5,a5,2
	addw	a0,a3,a0
	slliw	a0,a0,16
	sraiw	a0,a0,16
	bne	a4,a5,.L23
	ret
.L24:
	li	a0,0
	ret
	.size	sum2, .-sum2
	.align	2
	.globl	sum3
	.type	sum3, @function
sum3:
	blez	a1,.L29
	addiw	a1,a1,-1
	slli	a1,a1,32
	addi	a3,a0,4
	srli	a4,a1,30
	mv	a5,a0
	add	a4,a4,a3
	li	a0,0
.L28:
	lw	a3,0(a5)
	addi	a5,a5,4
	addw	a0,a3,a0
	bne	a4,a5,.L28
	ret
.L29:
	li	a0,0
	ret
	.size	sum3, .-sum3
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-32
	lui	t3,%hi(a.1576)
	lui	a4,%hi(b.1577)
	sd	s2,8(sp)
	sd	s0,24(sp)
	sd	s1,16(sp)
	addi	a2,t3,%lo(a.1576)
	addi	a5,a4,%lo(b.1577)
	lbu	a7,1(a2)
	lbu	t1,%lo(a.1576)(t3)
	lbu	t0,1(a5)
	lbu	a4,%lo(b.1577)(a4)
	lbu	a6,2(a2)
	lbu	t5,2(a5)
	lbu	a0,3(a2)
	lbu	s1,3(a5)
	lui	a1,%hi(c.1578)
	lbu	t4,4(a2)
	lbu	s0,4(a5)
	lui	t6,%hi(d.1579)
	addw	a3,t1,a7
	addi	a5,a1,%lo(c.1578)
	addw	a4,a4,t0
	addi	t2,t6,%lo(d.1579)
	lhu	t0,2(a5)
	add	a3,a6,a3
	add	a4,a4,t5
	lhu	t5,%lo(c.1578)(a1)
	lhu	s2,2(t2)
	lhu	a5,%lo(d.1579)(t6)
	add	a3,a3,a0
	add	a4,a4,s1
	lui	a1,%hi(.LANCHOR0)
	addi	a1,a1,%lo(.LANCHOR0)
	addw	a4,a4,s0
	addw	a3,a3,t4
	lw	s1,4(a1)
	lw	t2,0(a1)
	addw	t5,t5,t0
	andi	a3,a3,0xff
	andi	a4,a4,0xff
	lw	s0,20(a1)
	lw	t6,16(a1)
	lw	t0,8(a1)
	addw	a4,a4,a3
	addw	a5,a5,s2
	slliw	a3,t5,16
	sraiw	a3,a3,16
	lw	a1,24(a1)
	slliw	a5,a5,16
	addw	a4,a4,a3
	addw	t5,t2,s1
	sraiw	a5,a5,16
	addw	a3,t6,s0
	addw	a5,a4,a5
	addw	a4,t0,t5
	addw	a5,a5,a4
	addw	a4,a1,a3
	addw	a5,a5,a4
	andi	a5,a5,0xff
	addw	a0,a5,a0
	addw	t1,a5,t1
	addw	a7,a5,a7
	addw	a6,a5,a6
	addw	a5,a5,t4
	sb	a0,3(a2)
	sb	a7,1(a2)
	sb	a6,2(a2)
	sb	a5,4(a2)
	ld	s0,24(sp)
	sb	t1,%lo(a.1576)(t3)
	ld	s1,16(sp)
	ld	s2,8(sp)
	li	a0,0
	addi	sp,sp,32
	jr	ra
	.size	main, .-main
	.data
	.align	3
	.set	.LANCHOR0,. + 0
	.type	e.1580, @object
	.size	e.1580, 12
e.1580:
	.word	418326
	.word	3127321
	.word	321411
	.zero	4
	.type	f.1581, @object
	.size	f.1581, 12
f.1581:
	.word	1237231
	.word	4310892
	.word	321821
	.section	.sdata,"aw"
	.align	3
	.type	d.1579, @object
	.size	d.1579, 4
d.1579:
	.half	12451
	.half	14312
	.zero	4
	.type	c.1578, @object
	.size	c.1578, 4
c.1578:
	.half	124
	.half	12214
	.zero	4
	.type	b.1577, @object
	.size	b.1577, 5
b.1577:
	.string	"Hens"
	.zero	3
	.type	a.1576, @object
	.size	a.1576, 5
a.1576:
	.string	"Hans"
	.section	.srodata.cst8,"aM",@progbits,8
	.align	3
.LC0:
	.dword	9187201950435737471
.LC1:
	.dword	-9187201950435737472
	.ident	"GCC: (GNU) 8.2.0"

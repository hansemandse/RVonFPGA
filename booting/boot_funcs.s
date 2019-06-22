	.file	"boot_funcs.c"
	.option nopic
	.text
	.align	2
	.globl	read_uart
	.type	read_uart, @function
read_uart:
	li	a0,-1
	slli	a0,a0,63
	addi	a5,a0,17
 #APP
# 45 "boot_funcs.c" 1
	lb a5, 0(a5)
# 0 "" 2
 #NO_APP
	andi	a5,a5,0xff
	bnez	a5,.L5
.L4:
	j	.L4
.L5:
	addi	a0,a0,1
 #APP
# 33 "boot_funcs.c" 1
	lb a0, 0(a0)
# 0 "" 2
 #NO_APP
	andi	a0,a0,0xff
	ret
	.size	read_uart, .-read_uart
	.align	2
	.globl	write_uart
	.type	write_uart, @function
write_uart:
	li	a5,-1
	slli	a5,a5,63
	addi	a5,a5,1
 #APP
# 39 "boot_funcs.c" 1
	sb a0, 0(a5)
# 0 "" 2
 #NO_APP
	ret
	.size	write_uart, .-write_uart
	.align	2
	.globl	uart_data_ready
	.type	uart_data_ready, @function
uart_data_ready:
	li	a0,-1
	slli	a0,a0,63
	addi	a0,a0,17
 #APP
# 45 "boot_funcs.c" 1
	lb a0, 0(a0)
# 0 "" 2
 #NO_APP
	andi	a0,a0,0xff
	ret
	.size	uart_data_ready, .-uart_data_ready
	.align	2
	.globl	uart_write_ready
	.type	uart_write_ready, @function
uart_write_ready:
	li	a0,-1
	slli	a0,a0,63
	addi	a0,a0,16
 #APP
# 51 "boot_funcs.c" 1
	lb a0, 0(a0)
# 0 "" 2
 #NO_APP
	andi	a0,a0,0xff
	ret
	.size	uart_write_ready, .-uart_write_ready
	.align	2
	.globl	write_led_lo
	.type	write_led_lo, @function
write_led_lo:
	li	a5,-1
	slli	a5,a5,63
	addi	a5,a5,256
 #APP
# 56 "boot_funcs.c" 1
	sb a0, 0(a5)
# 0 "" 2
 #NO_APP
	ret
	.size	write_led_lo, .-write_led_lo
	.align	2
	.globl	write_led_hi
	.type	write_led_hi, @function
write_led_hi:
	li	a5,-1
	slli	a5,a5,63
	addi	a5,a5,257
 #APP
# 60 "boot_funcs.c" 1
	sb a0, 0(a5)
# 0 "" 2
 #NO_APP
	ret
	.size	write_led_hi, .-write_led_hi
	.align	2
	.globl	read_sw_lo
	.type	read_sw_lo, @function
read_sw_lo:
	li	a0,-1
	slli	a0,a0,63
	addi	a0,a0,256
 #APP
# 66 "boot_funcs.c" 1
	lb a0, 0(a0)
# 0 "" 2
 #NO_APP
	andi	a0,a0,0xff
	ret
	.size	read_sw_lo, .-read_sw_lo
	.align	2
	.globl	read_sw_hi
	.type	read_sw_hi, @function
read_sw_hi:
	li	a0,-1
	slli	a0,a0,63
	addi	a0,a0,257
 #APP
# 71 "boot_funcs.c" 1
	lb a0, 0(a0)
# 0 "" 2
 #NO_APP
	andi	a0,a0,0xff
	ret
	.size	read_sw_hi, .-read_sw_hi
	.align	2
	.globl	read_srec
	.type	read_srec, @function
read_srec:
	li	a7,-1
	slli	a7,a7,63
	addi	sp,sp,-144
	addi	t4,a7,1
 #APP
# 33 "boot_funcs.c" 1
	lb t1, 0(t4)
# 0 "" 2
 #NO_APP
	andi	t1,t1,0xff
	sd	s1,128(sp)
	sd	s2,120(sp)
	addiw	t6,t1,-49
	lui	s2,%hi(.LC0)
	lui	s1,%hi(.LC1)
	addiw	t5,t1,-55
	andi	t6,t6,0xff
	lui	a5,%hi(.L38)
	ld	a6,%lo(.LC0)(s2)
	ld	t3,%lo(.LC1)(s1)
	andi	t5,t5,0xff
	slli	t0,t6,2
	addi	a5,a5,%lo(.L38)
	sd	s0,136(sp)
	sd	s3,112(sp)
	sd	s4,104(sp)
	sd	s5,96(sp)
	sd	s6,88(sp)
	sd	s7,80(sp)
	li	s0,1
	mv	t2,t1
	mv	a1,t1
	mv	a0,t5
	add	t0,t0,a5
.L15:
	addi	a5,a7,17
 #APP
# 33 "boot_funcs.c" 1
	lb a4, 0(t4)
# 0 "" 2
# 45 "boot_funcs.c" 1
	lb a5, 0(a5)
# 0 "" 2
 #NO_APP
	andi	a4,a4,0xff
	andi	a5,a5,0xff
	li	a3,83
.L17:
	bnez	a5,.L72
.L66:
	j	.L66
.L72:
	bne	a4,a3,.L17
	addi	a5,a7,17
 #APP
# 45 "boot_funcs.c" 1
	lb a5, 0(a5)
# 0 "" 2
 #NO_APP
	andi	a5,a5,0xff
	bnez	a5,.L73
.L67:
	j	.L67
.L73:
	addiw	a5,t1,-48
	andi	a5,a5,0xff
	li	a4,9
	bgtu	a5,a4,.L48
	li	a5,57
	mv	a4,t5
	bgtu	t2,a5,.L23
	addiw	a4,t2,-48
	andi	a4,a4,0xff
.L23:
	addi	a5,a7,17
	sb	a4,0(sp)
 #APP
# 45 "boot_funcs.c" 1
	lb a5, 0(a5)
# 0 "" 2
 #NO_APP
	andi	a5,a5,0xff
	bnez	a5,.L74
.L69:
	j	.L69
.L74:
 #APP
# 33 "boot_funcs.c" 1
	lb a5, 0(t4)
# 0 "" 2
 #NO_APP
	li	a3,57
	andi	a5,a5,0xff
	bgtu	a5,a3,.L25
	addiw	a5,a5,-48
	andi	a5,a5,0xff
.L26:
	slli	s3,a4,4
	or	s3,a5,s3
	slliw	s3,s3,1
	sb	a5,1(sp)
	andi	s3,s3,0xff
	beqz	s3,.L27
	addiw	s4,s3,-1
	slli	s5,s4,32
	addi	a3,sp,1
	mv	a4,sp
	srli	s5,s5,32
	addiw	s7,a1,-48
	addi	a5,a7,17
	add	s5,a3,s5
 #APP
# 45 "boot_funcs.c" 1
	lb a5, 0(a5)
# 0 "" 2
 #NO_APP
	mv	a3,a4
	andi	a5,a5,0xff
	li	s6,57
	andi	s7,s7,0xff
.L28:
	bnez	a5,.L75
.L71:
	j	.L71
.L75:
	mv	a2,a0
	bgtu	a1,s6,.L30
	mv	a2,s7
.L30:
	sb	a2,0(a3)
	addi	a3,a3,1
	bne	a3,s5,.L28
	srliw	s4,s4,1
	slli	s4,s4,1
	addi	a3,a4,2
	add	s4,s4,a3
	j	.L32
.L77:
	addi	a3,a3,2
.L32:
	lbu	a2,0(a4)
	lbu	a5,1(a4)
	slliw	a2,a2,4
	andi	a5,a5,15
	or	a5,a5,a2
	sb	a5,0(a4)
	mv	a4,a3
	bne	a3,s4,.L77
.L27:
	srli	s3,s3,1
	sext.w	a2,s3
	addiw	a4,a2,-1
	sext.w	a3,a4
	blez	a3,.L49
	addiw	a5,a2,-2
	li	s4,12
	bleu	a5,s4,.L50
	srliw	a4,a4,3
	li	s4,1
	ld	a5,0(sp)
	beq	a4,s4,.L35
	ld	s4,8(sp)
	and	s5,a5,a6
	li	s6,2
	xor	a5,a5,s4
	and	s4,s4,a6
	add	s4,s5,s4
	and	a5,a5,t3
	xor	a5,s4,a5
	beq	a4,s6,.L35
	ld	s4,16(sp)
	and	s6,a5,a6
	li	s5,3
	xor	a5,s4,a5
	and	s4,s4,a6
	add	s4,s4,s6
	and	a5,a5,t3
	xor	a5,s4,a5
	beq	a4,s5,.L35
	ld	s4,24(sp)
	and	s5,a5,a6
	li	s6,4
	xor	a5,s4,a5
	and	s4,s4,a6
	add	s4,s5,s4
	and	a5,a5,t3
	xor	a5,s4,a5
	beq	a4,s6,.L35
	ld	s4,32(sp)
	and	s5,a5,a6
	li	s6,5
	xor	a5,a5,s4
	and	s4,s4,a6
	add	s4,s5,s4
	and	a5,a5,t3
	xor	a5,s4,a5
	beq	a4,s6,.L35
	ld	s4,40(sp)
	and	s5,a5,a6
	li	s6,6
	xor	a5,a5,s4
	and	s4,s4,a6
	add	s4,s5,s4
	and	a5,a5,t3
	xor	a5,s4,a5
	beq	a4,s6,.L35
	ld	s4,48(sp)
	and	s5,a5,a6
	li	s6,7
	xor	a5,a5,s4
	and	s4,s4,a6
	add	s4,s5,s4
	and	a5,a5,t3
	xor	a5,s4,a5
	beq	a4,s6,.L35
	ld	s4,56(sp)
	and	s5,a5,a6
	li	s6,8
	xor	a5,a5,s4
	and	s4,s4,a6
	add	s4,s5,s4
	and	a5,a5,t3
	xor	a5,s4,a5
	beq	a4,s6,.L35
	ld	a4,64(sp)
	ld	s5,%lo(.LC0)(s2)
	ld	s6,%lo(.LC1)(s1)
	xor	s4,a5,a4
	and	a5,a5,s5
	and	a4,a4,s5
	add	a4,a5,a4
	and	a5,s4,s6
	xor	a5,a4,a5
.L35:
	srli	a4,a5,8
	addw	a4,a4,a5
	srli	s4,a5,16
	addw	a4,a4,s3
	addw	a4,a4,s4
	srli	s4,a5,24
	addw	a4,a4,s4
	srli	s4,a5,32
	addw	a4,a4,s4
	srli	s4,a5,40
	addw	a4,a4,s4
	srli	s4,a5,48
	addw	a4,a4,s4
	srli	a5,a5,56
	addw	a5,a4,a5
	andi	s4,a3,-8
	andi	a5,a5,0xff
	sext.w	a4,s4
	beq	a3,s4,.L33
.L34:
	addi	s4,sp,80
	add	s4,s4,a4
	lbu	s5,-80(s4)
	addiw	s4,a4,1
	addw	a5,s5,a5
	andi	a5,a5,0xff
	bge	s4,a3,.L33
	addi	s5,sp,80
	add	s4,s5,s4
	lbu	s5,-80(s4)
	addiw	s4,a4,2
	addw	a5,s5,a5
	andi	a5,a5,0xff
	ble	a3,s4,.L33
	addi	s5,sp,80
	add	s4,s5,s4
	lbu	s5,-80(s4)
	addiw	s4,a4,3
	addw	a5,s5,a5
	andi	a5,a5,0xff
	ble	a3,s4,.L33
	addi	s5,sp,80
	add	s4,s5,s4
	lbu	s5,-80(s4)
	addiw	s4,a4,4
	addw	a5,s5,a5
	andi	a5,a5,0xff
	ble	a3,s4,.L33
	addi	s5,sp,80
	add	s4,s5,s4
	lbu	s5,-80(s4)
	addiw	s4,a4,5
	addw	a5,s5,a5
	andi	a5,a5,0xff
	ble	a3,s4,.L33
	addi	s5,sp,80
	add	s4,s5,s4
	lbu	s5,-80(s4)
	addiw	s4,a4,6
	addw	a5,s5,a5
	andi	a5,a5,0xff
	ble	a3,s4,.L33
	addi	s5,sp,80
	add	s4,s5,s4
	lbu	s5,-80(s4)
	addiw	s4,a4,7
	addw	a5,s5,a5
	andi	a5,a5,0xff
	ble	a3,s4,.L33
	addi	s5,sp,80
	add	s4,s5,s4
	lbu	s5,-80(s4)
	addiw	s4,a4,8
	addw	a5,s5,a5
	andi	a5,a5,0xff
	ble	a3,s4,.L33
	addi	s5,sp,80
	add	s4,s5,s4
	lbu	s5,-80(s4)
	addiw	s4,a4,9
	addw	a5,s5,a5
	andi	a5,a5,0xff
	ble	a3,s4,.L33
	addi	s5,sp,80
	add	s4,s5,s4
	lbu	s5,-80(s4)
	addiw	s4,a4,10
	addw	a5,s5,a5
	andi	a5,a5,0xff
	ble	a3,s4,.L33
	addi	s5,sp,80
	add	s4,s5,s4
	lbu	s5,-80(s4)
	addiw	s4,a4,11
	addw	a5,s5,a5
	andi	a5,a5,0xff
	ble	a3,s4,.L33
	addi	s5,sp,80
	add	s4,s5,s4
	lbu	s4,-80(s4)
	addiw	a4,a4,12
	addw	a5,s4,a5
	andi	a5,a5,0xff
	ble	a3,a4,.L33
	add	a4,s5,a4
	lbu	a4,-80(a4)
	addw	a5,a4,a5
	andi	a5,a5,0xff
.L33:
	addi	a4,sp,80
	add	a2,a4,a2
	lbu	a4,-80(a2)
	not	a4,a4
	andi	a4,a4,0xff
	bne	a4,a5,.L51
	li	a5,8
	bgtu	t6,a5,.L16
	lw	a5,0(t0)
	jr	a5
	.section	.rodata
	.align	2
	.align	2
.L38:
	.word	.L44
	.word	.L43
	.word	.L42
	.word	.L16
	.word	.L41
	.word	.L16
	.word	.L40
	.word	.L39
	.word	.L37
	.text
.L41:
	lbu	a4,0(sp)
	lbu	a3,1(sp)
	addiw	a5,s0,-2
	add	a4,a4,a3
	bne	a4,a5,.L78
.L16:
	addiw	s0,s0,1
	j	.L15
.L25:
	addiw	a5,a5,-55
	andi	a5,a5,0xff
	j	.L26
.L37:
	lbu	a0,0(sp)
	lbu	a4,1(sp)
	lbu	a3,3(sp)
	lbu	a5,2(sp)
	slliw	a0,a0,24
	slliw	a4,a4,16
	or	a0,a0,a4
	or	a0,a0,a3
	slliw	a5,a5,8
	or	a0,a0,a5
	sext.w	a0,a0
.L20:
	ld	s0,136(sp)
	ld	s1,128(sp)
	ld	s2,120(sp)
	ld	s3,112(sp)
	ld	s4,104(sp)
	ld	s5,96(sp)
	ld	s6,88(sp)
	ld	s7,80(sp)
	addi	sp,sp,144
	jr	ra
.L39:
	lbu	a0,0(sp)
	lbu	a5,1(sp)
	lbu	a4,2(sp)
	slliw	a0,a0,16
	slliw	a5,a5,8
	or	a0,a0,a5
	or	a0,a0,a4
	j	.L20
.L40:
	lhu	a5,0(sp)
	srliw	a4,a5,8
	slliw	a0,a5,8
	or	a0,a0,a4
	slli	a0,a0,48
	srli	a0,a0,48
	j	.L20
.L42:
	lbu	a2,0(sp)
	lbu	a4,1(sp)
	lbu	s4,3(sp)
	lbu	a5,2(sp)
	slliw	a2,a2,24
	slliw	a4,a4,16
	or	a2,a2,a4
	slliw	a5,a5,8
	or	a2,a2,s4
	or	a2,a2,a5
	li	a5,4
	sext.w	a2,a2
	ble	a3,a5,.L16
	addiw	a4,s3,-6
	slli	a4,a4,32
	srli	a4,a4,32
	mv	a5,sp
	addi	a3,sp,1
	li	s4,1
	add	a4,a4,a3
	sub	a2,a2,a5
	slli	s4,s4,60
.L47:
	add	a3,a2,a5
	lbu	s3,4(a5)
	or	a3,a3,s4
 #APP
# 133 "boot_funcs.c" 1
	sb s3, 0(a3)
# 0 "" 2
 #NO_APP
	addi	a5,a5,1
	bne	a5,a4,.L47
	addiw	s0,s0,1
	j	.L15
.L43:
	lbu	a2,0(sp)
	lbu	a5,1(sp)
	lbu	a4,2(sp)
	slliw	a2,a2,16
	slliw	a5,a5,8
	or	a2,a2,a5
	li	a5,3
	or	a2,a2,a4
	ble	a3,a5,.L16
	addiw	s3,s3,-5
	slli	s3,s3,32
	srli	s3,s3,32
	mv	a5,sp
	addi	a4,sp,1
	li	s4,1
	add	s3,s3,a4
	sub	a2,a2,a5
	slli	s4,s4,60
.L46:
	add	a4,a2,a5
	lbu	a3,3(a5)
	or	a4,a4,s4
 #APP
# 126 "boot_funcs.c" 1
	sb a3, 0(a4)
# 0 "" 2
 #NO_APP
	addi	a5,a5,1
	bne	a5,s3,.L46
	addiw	s0,s0,1
	j	.L15
.L44:
	lhu	a5,0(sp)
	li	a4,2
	srliw	s4,a5,8
	slliw	a2,a5,8
	or	a2,a2,s4
	slli	a2,a2,48
	srli	a2,a2,48
	ble	a3,a4,.L16
	addiw	s3,s3,-4
	slli	s3,s3,32
	srli	s3,s3,32
	mv	a5,sp
	addi	a4,sp,1
	li	s4,1
	add	s3,s3,a4
	sub	a2,a2,a5
	slli	s4,s4,60
.L45:
	add	a4,a2,a5
	lbu	a3,2(a5)
	or	a4,a4,s4
 #APP
# 119 "boot_funcs.c" 1
	sb a3, 0(a4)
# 0 "" 2
 #NO_APP
	addi	a5,a5,1
	bne	a5,s3,.L45
	addiw	s0,s0,1
	j	.L15
.L49:
	mv	a5,s3
	j	.L33
.L50:
	mv	a5,s3
	li	a4,0
	j	.L34
.L48:
	li	a0,-1
	j	.L20
.L51:
	li	a0,2
	j	.L20
.L78:
	li	a0,3
	j	.L20
	.size	read_srec, .-read_srec
	.section	.srodata.cst8,"aM",@progbits,8
	.align	3
.LC0:
	.dword	9187201950435737471
.LC1:
	.dword	-9187201950435737472
	.ident	"GCC: (GNU) 8.2.0"

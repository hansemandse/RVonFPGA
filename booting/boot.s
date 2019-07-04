
boot.o:     file format elf64-littleriscv
boot.o
architecture: riscv:rv64, flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
start address 0x0000000000000000

Program Header:
    LOAD off    0x0000000000001000 vaddr 0x0000000000000000 paddr 0x0000000000000000 align 2**12
         filesz 0x0000000000000f10 memsz 0x0000000000000f10 flags r-x

Sections:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .text         0000087c  0000000000000000  0000000000000000  00001000  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .rodata       00000024  000000000000087c  000000000000087c  0000187c  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .sdata        00000010  0000000000000f00  0000000000000f00  00001f00  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
SYMBOL TABLE:
0000000000000000 l    d  .text	0000000000000000 .text
000000000000087c l    d  .rodata	0000000000000000 .rodata
0000000000000f00 l    d  .sdata	0000000000000000 .sdata
0000000000000000 l    df *ABS*	0000000000000000 boot_rom.s
1000000000000000 l       *ABS*	0000000000000000 MEM_START
100000000000f000 l       *ABS*	0000000000000000 SP_START
000000000000000c l       .text	0000000000000000 init
0000000000000034 l       .text	0000000000000000 final
0000000000000000 l    df *ABS*	0000000000000000 RVonFPGA_boot_funcs.c
0000000000001700 g       *ABS*	0000000000000000 __global_pointer$
0000000000000068 g     F .text	000000000000002c read_uart
0000000000000f00 g       .sdata	0000000000000000 __SDATA_BEGIN__
0000000000000038 g     F .text	0000000000000018 uart_stb_in
00000000000000a8 g     F .text	0000000000000014 write_led_lo
00000000000000bc g     F .text	0000000000000014 write_led_hi
0000000000000100 g     F .text	0000000000000088 test
0000000000000000 g     F .text	0000000000000038 _start
0000000000000094 g     F .text	0000000000000014 write_uart
0000000000000188 g     F .text	00000000000006f4 read_srec
0000000000000f10 g       .sdata	0000000000000000 __BSS_END__
0000000000000f10 g       .sdata	0000000000000000 __bss_start
0000000000000f00 g       .rodata	0000000000000000 __DATA_BEGIN__
0000000000000f10 g       .sdata	0000000000000000 _edata
0000000000000f10 g       .sdata	0000000000000000 _end
00000000000000e8 g     F .text	0000000000000018 read_sw_hi
00000000000000d0 g     F .text	0000000000000018 read_sw_lo
0000000000000050 g     F .text	0000000000000018 uart_stb_out



Disassembly of section .text:

0000000000000000 <_start>:
   0:	00000513          	li	a0,0
   4:	0b8000ef          	jal	ra,bc <write_led_hi>
   8:	0a0000ef          	jal	ra,a8 <write_led_lo>

000000000000000c <init>:
   c:	0010011b          	addiw	sp,zero,1
  10:	03011113          	slli	sp,sp,0x30
  14:	00f10113          	addi	sp,sp,15
  18:	00c11113          	slli	sp,sp,0xc
  1c:	00001197          	auipc	gp,0x1
  20:	6e418193          	addi	gp,gp,1764 # 1700 <__global_pointer$>
  24:	0dc000ef          	jal	ra,100 <test>
  28:	0010059b          	addiw	a1,zero,1
  2c:	03c59593          	slli	a1,a1,0x3c
  30:	00b56533          	or	a0,a0,a1

0000000000000034 <final>:
  34:	00050067          	jr	a0

0000000000000038 <uart_stb_in>:
  38:	fff00513          	li	a0,-1
  3c:	03f51513          	slli	a0,a0,0x3f
  40:	00350513          	addi	a0,a0,3
  44:	00050503          	lb	a0,0(a0)
  48:	0ff57513          	andi	a0,a0,255
  4c:	00008067          	ret

0000000000000050 <uart_stb_out>:
  50:	fff00513          	li	a0,-1
  54:	03f51513          	slli	a0,a0,0x3f
  58:	00250513          	addi	a0,a0,2
  5c:	00050503          	lb	a0,0(a0)
  60:	0ff57513          	andi	a0,a0,255
  64:	00008067          	ret

0000000000000068 <read_uart>:
  68:	fff00513          	li	a0,-1
  6c:	03f51513          	slli	a0,a0,0x3f
  70:	00350793          	addi	a5,a0,3
  74:	00078783          	lb	a5,0(a5)
  78:	0ff7f793          	andi	a5,a5,255
  7c:	00079463          	bnez	a5,84 <read_uart+0x1c>
  80:	0000006f          	j	80 <read_uart+0x18>
  84:	00150513          	addi	a0,a0,1
  88:	00050503          	lb	a0,0(a0)
  8c:	0ff57513          	andi	a0,a0,255
  90:	00008067          	ret

0000000000000094 <write_uart>:
  94:	fff00793          	li	a5,-1
  98:	03f79793          	slli	a5,a5,0x3f
  9c:	00178793          	addi	a5,a5,1
  a0:	00a78023          	sb	a0,0(a5)
  a4:	00008067          	ret

00000000000000a8 <write_led_lo>:
  a8:	fff00793          	li	a5,-1
  ac:	03f79793          	slli	a5,a5,0x3f
  b0:	00478793          	addi	a5,a5,4
  b4:	00a78023          	sb	a0,0(a5)
  b8:	00008067          	ret

00000000000000bc <write_led_hi>:
  bc:	fff00793          	li	a5,-1
  c0:	03f79793          	slli	a5,a5,0x3f
  c4:	00578793          	addi	a5,a5,5
  c8:	00a78023          	sb	a0,0(a5)
  cc:	00008067          	ret

00000000000000d0 <read_sw_lo>:
  d0:	fff00513          	li	a0,-1
  d4:	03f51513          	slli	a0,a0,0x3f
  d8:	00450513          	addi	a0,a0,4
  dc:	00050503          	lb	a0,0(a0)
  e0:	0ff57513          	andi	a0,a0,255
  e4:	00008067          	ret

00000000000000e8 <read_sw_hi>:
  e8:	fff00513          	li	a0,-1
  ec:	03f51513          	slli	a0,a0,0x3f
  f0:	00550513          	addi	a0,a0,5
  f4:	00050503          	lb	a0,0(a0)
  f8:	0ff57513          	andi	a0,a0,255
  fc:	00008067          	ret

0000000000000100 <test>:
 100:	fff00613          	li	a2,-1
 104:	03f61613          	slli	a2,a2,0x3f
 108:	00560593          	addi	a1,a2,5
 10c:	00058783          	lb	a5,0(a1)
 110:	0ff7f793          	andi	a5,a5,255
 114:	00460613          	addi	a2,a2,4
 118:	00879793          	slli	a5,a5,0x8
 11c:	00060703          	lb	a4,0(a2)
 120:	0ff77713          	andi	a4,a4,255
 124:	00f76733          	or	a4,a4,a5
 128:	0107171b          	slliw	a4,a4,0x10
 12c:	ff010113          	addi	sp,sp,-16
 130:	4107571b          	sraiw	a4,a4,0x10
 134:	06300693          	li	a3,99
 138:	00012623          	sw	zero,12(sp)
 13c:	00c12783          	lw	a5,12(sp)
 140:	0007879b          	sext.w	a5,a5
 144:	fef6cae3          	blt	a3,a5,138 <test+0x38>
 148:	00c12783          	lw	a5,12(sp)
 14c:	0007879b          	sext.w	a5,a5
 150:	00079e63          	bnez	a5,16c <test+0x6c>
 154:	00e60023          	sb	a4,0(a2)
 158:	4087579b          	sraiw	a5,a4,0x8
 15c:	00f58023          	sb	a5,0(a1)
 160:	0017071b          	addiw	a4,a4,1
 164:	0107171b          	slliw	a4,a4,0x10
 168:	4107571b          	sraiw	a4,a4,0x10
 16c:	00c12783          	lw	a5,12(sp)
 170:	0017879b          	addiw	a5,a5,1
 174:	00f12623          	sw	a5,12(sp)
 178:	00c12783          	lw	a5,12(sp)
 17c:	0007879b          	sext.w	a5,a5
 180:	fcf6d4e3          	bge	a3,a5,148 <test+0x48>
 184:	fb5ff06f          	j	138 <test+0x38>

0000000000000188 <read_srec>:
 188:	fff00893          	li	a7,-1
 18c:	03f89893          	slli	a7,a7,0x3f
 190:	f7010113          	addi	sp,sp,-144
 194:	00188e93          	addi	t4,a7,1
 198:	000e8303          	lb	t1,0(t4)
 19c:	0ff37313          	andi	t1,t1,255
 1a0:	08913023          	sd	s1,128(sp)
 1a4:	07213c23          	sd	s2,120(sp)
 1a8:	fcf30f9b          	addiw	t6,t1,-49
 1ac:	00001937          	lui	s2,0x1
 1b0:	000014b7          	lui	s1,0x1
 1b4:	fc930f1b          	addiw	t5,t1,-55
 1b8:	0fffff93          	andi	t6,t6,255
 1bc:	000017b7          	lui	a5,0x1
 1c0:	f0093803          	ld	a6,-256(s2) # f00 <__DATA_BEGIN__>
 1c4:	f084be03          	ld	t3,-248(s1) # f08 <__DATA_BEGIN__+0x8>
 1c8:	0fff7f13          	andi	t5,t5,255
 1cc:	002f9293          	slli	t0,t6,0x2
 1d0:	87c78793          	addi	a5,a5,-1924 # 87c <read_srec+0x6f4>
 1d4:	08813423          	sd	s0,136(sp)
 1d8:	07313823          	sd	s3,112(sp)
 1dc:	07413423          	sd	s4,104(sp)
 1e0:	07513023          	sd	s5,96(sp)
 1e4:	05613c23          	sd	s6,88(sp)
 1e8:	05713823          	sd	s7,80(sp)
 1ec:	00100413          	li	s0,1
 1f0:	00030393          	mv	t2,t1
 1f4:	00030593          	mv	a1,t1
 1f8:	000f0513          	mv	a0,t5
 1fc:	00f282b3          	add	t0,t0,a5
 200:	00388793          	addi	a5,a7,3
 204:	000e8703          	lb	a4,0(t4)
 208:	00078783          	lb	a5,0(a5)
 20c:	0ff77713          	andi	a4,a4,255
 210:	0ff7f793          	andi	a5,a5,255
 214:	05300693          	li	a3,83
 218:	00079463          	bnez	a5,220 <read_srec+0x98>
 21c:	0000006f          	j	21c <read_srec+0x94>
 220:	fed71ce3          	bne	a4,a3,218 <read_srec+0x90>
 224:	00388793          	addi	a5,a7,3
 228:	00078783          	lb	a5,0(a5)
 22c:	0ff7f793          	andi	a5,a5,255
 230:	00079463          	bnez	a5,238 <read_srec+0xb0>
 234:	0000006f          	j	234 <read_srec+0xac>
 238:	fd03079b          	addiw	a5,t1,-48
 23c:	0ff7f793          	andi	a5,a5,255
 240:	00900713          	li	a4,9
 244:	62f76063          	bltu	a4,a5,864 <read_srec+0x6dc>
 248:	03900793          	li	a5,57
 24c:	000f0713          	mv	a4,t5
 250:	0077e663          	bltu	a5,t2,25c <read_srec+0xd4>
 254:	fd03871b          	addiw	a4,t2,-48
 258:	0ff77713          	andi	a4,a4,255
 25c:	00388793          	addi	a5,a7,3
 260:	00e10023          	sb	a4,0(sp)
 264:	00078783          	lb	a5,0(a5)
 268:	0ff7f793          	andi	a5,a5,255
 26c:	00079463          	bnez	a5,274 <read_srec+0xec>
 270:	0000006f          	j	270 <read_srec+0xe8>
 274:	000e8783          	lb	a5,0(t4)
 278:	03900693          	li	a3,57
 27c:	0ff7f793          	andi	a5,a5,255
 280:	3ef6e863          	bltu	a3,a5,670 <read_srec+0x4e8>
 284:	fd07879b          	addiw	a5,a5,-48
 288:	0ff7f793          	andi	a5,a5,255
 28c:	00471993          	slli	s3,a4,0x4
 290:	0137e9b3          	or	s3,a5,s3
 294:	0019999b          	slliw	s3,s3,0x1
 298:	00f100a3          	sb	a5,1(sp)
 29c:	0ff9f993          	andi	s3,s3,255
 2a0:	08098863          	beqz	s3,330 <read_srec+0x1a8>
 2a4:	fff98a1b          	addiw	s4,s3,-1
 2a8:	020a1a93          	slli	s5,s4,0x20
 2ac:	00110693          	addi	a3,sp,1
 2b0:	00010713          	mv	a4,sp
 2b4:	020ada93          	srli	s5,s5,0x20
 2b8:	fd058b9b          	addiw	s7,a1,-48
 2bc:	00388793          	addi	a5,a7,3
 2c0:	01568ab3          	add	s5,a3,s5
 2c4:	00078783          	lb	a5,0(a5)
 2c8:	00070693          	mv	a3,a4
 2cc:	0ff7f793          	andi	a5,a5,255
 2d0:	03900b13          	li	s6,57
 2d4:	0ffbfb93          	andi	s7,s7,255
 2d8:	00079463          	bnez	a5,2e0 <read_srec+0x158>
 2dc:	0000006f          	j	2dc <read_srec+0x154>
 2e0:	00050613          	mv	a2,a0
 2e4:	00bb6463          	bltu	s6,a1,2ec <read_srec+0x164>
 2e8:	000b8613          	mv	a2,s7
 2ec:	00c68023          	sb	a2,0(a3)
 2f0:	00168693          	addi	a3,a3,1
 2f4:	ff5692e3          	bne	a3,s5,2d8 <read_srec+0x150>
 2f8:	001a5a1b          	srliw	s4,s4,0x1
 2fc:	001a1a13          	slli	s4,s4,0x1
 300:	00270693          	addi	a3,a4,2
 304:	00da0a33          	add	s4,s4,a3
 308:	0080006f          	j	310 <read_srec+0x188>
 30c:	00268693          	addi	a3,a3,2
 310:	00074603          	lbu	a2,0(a4)
 314:	00174783          	lbu	a5,1(a4)
 318:	0046161b          	slliw	a2,a2,0x4
 31c:	00f7f793          	andi	a5,a5,15
 320:	00c7e7b3          	or	a5,a5,a2
 324:	00f70023          	sb	a5,0(a4)
 328:	00068713          	mv	a4,a3
 32c:	ff4690e3          	bne	a3,s4,30c <read_srec+0x184>
 330:	0019d993          	srli	s3,s3,0x1
 334:	0009861b          	sext.w	a2,s3
 338:	fff6071b          	addiw	a4,a2,-1
 33c:	0007069b          	sext.w	a3,a4
 340:	50d05863          	blez	a3,850 <read_srec+0x6c8>
 344:	ffe6079b          	addiw	a5,a2,-2
 348:	00c00a13          	li	s4,12
 34c:	50fa7663          	bgeu	s4,a5,858 <read_srec+0x6d0>
 350:	0037571b          	srliw	a4,a4,0x3
 354:	00100a13          	li	s4,1
 358:	00013783          	ld	a5,0(sp)
 35c:	13470263          	beq	a4,s4,480 <read_srec+0x2f8>
 360:	00813a03          	ld	s4,8(sp)
 364:	0107fab3          	and	s5,a5,a6
 368:	00200b13          	li	s6,2
 36c:	0147c7b3          	xor	a5,a5,s4
 370:	010a7a33          	and	s4,s4,a6
 374:	014a8a33          	add	s4,s5,s4
 378:	01c7f7b3          	and	a5,a5,t3
 37c:	00fa47b3          	xor	a5,s4,a5
 380:	11670063          	beq	a4,s6,480 <read_srec+0x2f8>
 384:	01013a03          	ld	s4,16(sp)
 388:	0107fb33          	and	s6,a5,a6
 38c:	00300a93          	li	s5,3
 390:	00fa47b3          	xor	a5,s4,a5
 394:	010a7a33          	and	s4,s4,a6
 398:	016a0a33          	add	s4,s4,s6
 39c:	01c7f7b3          	and	a5,a5,t3
 3a0:	00fa47b3          	xor	a5,s4,a5
 3a4:	0d570e63          	beq	a4,s5,480 <read_srec+0x2f8>
 3a8:	01813a03          	ld	s4,24(sp)
 3ac:	0107fab3          	and	s5,a5,a6
 3b0:	00400b13          	li	s6,4
 3b4:	00fa47b3          	xor	a5,s4,a5
 3b8:	010a7a33          	and	s4,s4,a6
 3bc:	014a8a33          	add	s4,s5,s4
 3c0:	01c7f7b3          	and	a5,a5,t3
 3c4:	00fa47b3          	xor	a5,s4,a5
 3c8:	0b670c63          	beq	a4,s6,480 <read_srec+0x2f8>
 3cc:	02013a03          	ld	s4,32(sp)
 3d0:	0107fab3          	and	s5,a5,a6
 3d4:	00500b13          	li	s6,5
 3d8:	0147c7b3          	xor	a5,a5,s4
 3dc:	010a7a33          	and	s4,s4,a6
 3e0:	014a8a33          	add	s4,s5,s4
 3e4:	01c7f7b3          	and	a5,a5,t3
 3e8:	00fa47b3          	xor	a5,s4,a5
 3ec:	09670a63          	beq	a4,s6,480 <read_srec+0x2f8>
 3f0:	02813a03          	ld	s4,40(sp)
 3f4:	0107fab3          	and	s5,a5,a6
 3f8:	00600b13          	li	s6,6
 3fc:	0147c7b3          	xor	a5,a5,s4
 400:	010a7a33          	and	s4,s4,a6
 404:	014a8a33          	add	s4,s5,s4
 408:	01c7f7b3          	and	a5,a5,t3
 40c:	00fa47b3          	xor	a5,s4,a5
 410:	07670863          	beq	a4,s6,480 <read_srec+0x2f8>
 414:	03013a03          	ld	s4,48(sp)
 418:	0107fab3          	and	s5,a5,a6
 41c:	00700b13          	li	s6,7
 420:	0147c7b3          	xor	a5,a5,s4
 424:	010a7a33          	and	s4,s4,a6
 428:	014a8a33          	add	s4,s5,s4
 42c:	01c7f7b3          	and	a5,a5,t3
 430:	00fa47b3          	xor	a5,s4,a5
 434:	05670663          	beq	a4,s6,480 <read_srec+0x2f8>
 438:	03813a03          	ld	s4,56(sp)
 43c:	0107fab3          	and	s5,a5,a6
 440:	00800b13          	li	s6,8
 444:	0147c7b3          	xor	a5,a5,s4
 448:	010a7a33          	and	s4,s4,a6
 44c:	014a8a33          	add	s4,s5,s4
 450:	01c7f7b3          	and	a5,a5,t3
 454:	00fa47b3          	xor	a5,s4,a5
 458:	03670463          	beq	a4,s6,480 <read_srec+0x2f8>
 45c:	04013703          	ld	a4,64(sp)
 460:	f0093a83          	ld	s5,-256(s2)
 464:	f084bb03          	ld	s6,-248(s1)
 468:	00e7ca33          	xor	s4,a5,a4
 46c:	0157f7b3          	and	a5,a5,s5
 470:	01577733          	and	a4,a4,s5
 474:	00e78733          	add	a4,a5,a4
 478:	016a77b3          	and	a5,s4,s6
 47c:	00f747b3          	xor	a5,a4,a5
 480:	0087d713          	srli	a4,a5,0x8
 484:	00f7073b          	addw	a4,a4,a5
 488:	0107da13          	srli	s4,a5,0x10
 48c:	0137073b          	addw	a4,a4,s3
 490:	0147073b          	addw	a4,a4,s4
 494:	0187da13          	srli	s4,a5,0x18
 498:	0147073b          	addw	a4,a4,s4
 49c:	0207da13          	srli	s4,a5,0x20
 4a0:	0147073b          	addw	a4,a4,s4
 4a4:	0287da13          	srli	s4,a5,0x28
 4a8:	0147073b          	addw	a4,a4,s4
 4ac:	0307da13          	srli	s4,a5,0x30
 4b0:	0147073b          	addw	a4,a4,s4
 4b4:	0387d793          	srli	a5,a5,0x38
 4b8:	00f707bb          	addw	a5,a4,a5
 4bc:	ff86fa13          	andi	s4,a3,-8
 4c0:	0ff7f793          	andi	a5,a5,255
 4c4:	000a071b          	sext.w	a4,s4
 4c8:	17468263          	beq	a3,s4,62c <read_srec+0x4a4>
 4cc:	05010a13          	addi	s4,sp,80
 4d0:	00ea0a33          	add	s4,s4,a4
 4d4:	fb0a4a83          	lbu	s5,-80(s4)
 4d8:	00170a1b          	addiw	s4,a4,1
 4dc:	00fa87bb          	addw	a5,s5,a5
 4e0:	0ff7f793          	andi	a5,a5,255
 4e4:	14da5463          	bge	s4,a3,62c <read_srec+0x4a4>
 4e8:	05010a93          	addi	s5,sp,80
 4ec:	014a8a33          	add	s4,s5,s4
 4f0:	fb0a4a83          	lbu	s5,-80(s4)
 4f4:	00270a1b          	addiw	s4,a4,2
 4f8:	00fa87bb          	addw	a5,s5,a5
 4fc:	0ff7f793          	andi	a5,a5,255
 500:	12da5663          	bge	s4,a3,62c <read_srec+0x4a4>
 504:	05010a93          	addi	s5,sp,80
 508:	014a8a33          	add	s4,s5,s4
 50c:	fb0a4a83          	lbu	s5,-80(s4)
 510:	00370a1b          	addiw	s4,a4,3
 514:	00fa87bb          	addw	a5,s5,a5
 518:	0ff7f793          	andi	a5,a5,255
 51c:	10da5863          	bge	s4,a3,62c <read_srec+0x4a4>
 520:	05010a93          	addi	s5,sp,80
 524:	014a8a33          	add	s4,s5,s4
 528:	fb0a4a83          	lbu	s5,-80(s4)
 52c:	00470a1b          	addiw	s4,a4,4
 530:	00fa87bb          	addw	a5,s5,a5
 534:	0ff7f793          	andi	a5,a5,255
 538:	0eda5a63          	bge	s4,a3,62c <read_srec+0x4a4>
 53c:	05010a93          	addi	s5,sp,80
 540:	014a8a33          	add	s4,s5,s4
 544:	fb0a4a83          	lbu	s5,-80(s4)
 548:	00570a1b          	addiw	s4,a4,5
 54c:	00fa87bb          	addw	a5,s5,a5
 550:	0ff7f793          	andi	a5,a5,255
 554:	0cda5c63          	bge	s4,a3,62c <read_srec+0x4a4>
 558:	05010a93          	addi	s5,sp,80
 55c:	014a8a33          	add	s4,s5,s4
 560:	fb0a4a83          	lbu	s5,-80(s4)
 564:	00670a1b          	addiw	s4,a4,6
 568:	00fa87bb          	addw	a5,s5,a5
 56c:	0ff7f793          	andi	a5,a5,255
 570:	0ada5e63          	bge	s4,a3,62c <read_srec+0x4a4>
 574:	05010a93          	addi	s5,sp,80
 578:	014a8a33          	add	s4,s5,s4
 57c:	fb0a4a83          	lbu	s5,-80(s4)
 580:	00770a1b          	addiw	s4,a4,7
 584:	00fa87bb          	addw	a5,s5,a5
 588:	0ff7f793          	andi	a5,a5,255
 58c:	0ada5063          	bge	s4,a3,62c <read_srec+0x4a4>
 590:	05010a93          	addi	s5,sp,80
 594:	014a8a33          	add	s4,s5,s4
 598:	fb0a4a83          	lbu	s5,-80(s4)
 59c:	00870a1b          	addiw	s4,a4,8
 5a0:	00fa87bb          	addw	a5,s5,a5
 5a4:	0ff7f793          	andi	a5,a5,255
 5a8:	08da5263          	bge	s4,a3,62c <read_srec+0x4a4>
 5ac:	05010a93          	addi	s5,sp,80
 5b0:	014a8a33          	add	s4,s5,s4
 5b4:	fb0a4a83          	lbu	s5,-80(s4)
 5b8:	00970a1b          	addiw	s4,a4,9
 5bc:	00fa87bb          	addw	a5,s5,a5
 5c0:	0ff7f793          	andi	a5,a5,255
 5c4:	06da5463          	bge	s4,a3,62c <read_srec+0x4a4>
 5c8:	05010a93          	addi	s5,sp,80
 5cc:	014a8a33          	add	s4,s5,s4
 5d0:	fb0a4a83          	lbu	s5,-80(s4)
 5d4:	00a70a1b          	addiw	s4,a4,10
 5d8:	00fa87bb          	addw	a5,s5,a5
 5dc:	0ff7f793          	andi	a5,a5,255
 5e0:	04da5663          	bge	s4,a3,62c <read_srec+0x4a4>
 5e4:	05010a93          	addi	s5,sp,80
 5e8:	014a8a33          	add	s4,s5,s4
 5ec:	fb0a4a83          	lbu	s5,-80(s4)
 5f0:	00b70a1b          	addiw	s4,a4,11
 5f4:	00fa87bb          	addw	a5,s5,a5
 5f8:	0ff7f793          	andi	a5,a5,255
 5fc:	02da5863          	bge	s4,a3,62c <read_srec+0x4a4>
 600:	05010a93          	addi	s5,sp,80
 604:	014a8a33          	add	s4,s5,s4
 608:	fb0a4a03          	lbu	s4,-80(s4)
 60c:	00c7071b          	addiw	a4,a4,12
 610:	00fa07bb          	addw	a5,s4,a5
 614:	0ff7f793          	andi	a5,a5,255
 618:	00d75a63          	bge	a4,a3,62c <read_srec+0x4a4>
 61c:	00ea8733          	add	a4,s5,a4
 620:	fb074703          	lbu	a4,-80(a4)
 624:	00f707bb          	addw	a5,a4,a5
 628:	0ff7f793          	andi	a5,a5,255
 62c:	05010713          	addi	a4,sp,80
 630:	00c70633          	add	a2,a4,a2
 634:	fb064703          	lbu	a4,-80(a2)
 638:	fff74713          	not	a4,a4
 63c:	0ff77713          	andi	a4,a4,255
 640:	22f71663          	bne	a4,a5,86c <read_srec+0x6e4>
 644:	00800793          	li	a5,8
 648:	03f7e063          	bltu	a5,t6,668 <read_srec+0x4e0>
 64c:	0002a783          	lw	a5,0(t0)
 650:	00078067          	jr	a5
 654:	00014703          	lbu	a4,0(sp)
 658:	00114683          	lbu	a3,1(sp)
 65c:	ffe4079b          	addiw	a5,s0,-2
 660:	00d70733          	add	a4,a4,a3
 664:	20f71863          	bne	a4,a5,874 <read_srec+0x6ec>
 668:	0014041b          	addiw	s0,s0,1
 66c:	b95ff06f          	j	200 <read_srec+0x78>
 670:	fc97879b          	addiw	a5,a5,-55
 674:	0ff7f793          	andi	a5,a5,255
 678:	c15ff06f          	j	28c <read_srec+0x104>
 67c:	00014503          	lbu	a0,0(sp)
 680:	00114703          	lbu	a4,1(sp)
 684:	00314683          	lbu	a3,3(sp)
 688:	00214783          	lbu	a5,2(sp)
 68c:	0185151b          	slliw	a0,a0,0x18
 690:	0107171b          	slliw	a4,a4,0x10
 694:	00e56533          	or	a0,a0,a4
 698:	00d56533          	or	a0,a0,a3
 69c:	0087979b          	slliw	a5,a5,0x8
 6a0:	00f56533          	or	a0,a0,a5
 6a4:	0005051b          	sext.w	a0,a0
 6a8:	08813403          	ld	s0,136(sp)
 6ac:	08013483          	ld	s1,128(sp)
 6b0:	07813903          	ld	s2,120(sp)
 6b4:	07013983          	ld	s3,112(sp)
 6b8:	06813a03          	ld	s4,104(sp)
 6bc:	06013a83          	ld	s5,96(sp)
 6c0:	05813b03          	ld	s6,88(sp)
 6c4:	05013b83          	ld	s7,80(sp)
 6c8:	09010113          	addi	sp,sp,144
 6cc:	00008067          	ret
 6d0:	00014503          	lbu	a0,0(sp)
 6d4:	00114783          	lbu	a5,1(sp)
 6d8:	00214703          	lbu	a4,2(sp)
 6dc:	0105151b          	slliw	a0,a0,0x10
 6e0:	0087979b          	slliw	a5,a5,0x8
 6e4:	00f56533          	or	a0,a0,a5
 6e8:	00e56533          	or	a0,a0,a4
 6ec:	fbdff06f          	j	6a8 <read_srec+0x520>
 6f0:	00015783          	lhu	a5,0(sp)
 6f4:	0087d71b          	srliw	a4,a5,0x8
 6f8:	0087951b          	slliw	a0,a5,0x8
 6fc:	00e56533          	or	a0,a0,a4
 700:	03051513          	slli	a0,a0,0x30
 704:	03055513          	srli	a0,a0,0x30
 708:	fa1ff06f          	j	6a8 <read_srec+0x520>
 70c:	00014603          	lbu	a2,0(sp)
 710:	00114703          	lbu	a4,1(sp)
 714:	00314a03          	lbu	s4,3(sp)
 718:	00214783          	lbu	a5,2(sp)
 71c:	0186161b          	slliw	a2,a2,0x18
 720:	0107171b          	slliw	a4,a4,0x10
 724:	00e66633          	or	a2,a2,a4
 728:	0087979b          	slliw	a5,a5,0x8
 72c:	01466633          	or	a2,a2,s4
 730:	00f66633          	or	a2,a2,a5
 734:	00400793          	li	a5,4
 738:	0006061b          	sext.w	a2,a2
 73c:	f2d7d6e3          	bge	a5,a3,668 <read_srec+0x4e0>
 740:	ffa9871b          	addiw	a4,s3,-6
 744:	02071713          	slli	a4,a4,0x20
 748:	02075713          	srli	a4,a4,0x20
 74c:	00010793          	mv	a5,sp
 750:	00110693          	addi	a3,sp,1
 754:	00100a13          	li	s4,1
 758:	00d70733          	add	a4,a4,a3
 75c:	40f60633          	sub	a2,a2,a5
 760:	03ca1a13          	slli	s4,s4,0x3c
 764:	00f606b3          	add	a3,a2,a5
 768:	0047c983          	lbu	s3,4(a5)
 76c:	0146e6b3          	or	a3,a3,s4
 770:	01368023          	sb	s3,0(a3)
 774:	00178793          	addi	a5,a5,1
 778:	fee796e3          	bne	a5,a4,764 <read_srec+0x5dc>
 77c:	0014041b          	addiw	s0,s0,1
 780:	a81ff06f          	j	200 <read_srec+0x78>
 784:	00014603          	lbu	a2,0(sp)
 788:	00114783          	lbu	a5,1(sp)
 78c:	00214703          	lbu	a4,2(sp)
 790:	0106161b          	slliw	a2,a2,0x10
 794:	0087979b          	slliw	a5,a5,0x8
 798:	00f66633          	or	a2,a2,a5
 79c:	00300793          	li	a5,3
 7a0:	00e66633          	or	a2,a2,a4
 7a4:	ecd7d2e3          	bge	a5,a3,668 <read_srec+0x4e0>
 7a8:	ffb9899b          	addiw	s3,s3,-5
 7ac:	02099993          	slli	s3,s3,0x20
 7b0:	0209d993          	srli	s3,s3,0x20
 7b4:	00010793          	mv	a5,sp
 7b8:	00110713          	addi	a4,sp,1
 7bc:	00100a13          	li	s4,1
 7c0:	00e989b3          	add	s3,s3,a4
 7c4:	40f60633          	sub	a2,a2,a5
 7c8:	03ca1a13          	slli	s4,s4,0x3c
 7cc:	00f60733          	add	a4,a2,a5
 7d0:	0037c683          	lbu	a3,3(a5)
 7d4:	01476733          	or	a4,a4,s4
 7d8:	00d70023          	sb	a3,0(a4)
 7dc:	00178793          	addi	a5,a5,1
 7e0:	ff3796e3          	bne	a5,s3,7cc <read_srec+0x644>
 7e4:	0014041b          	addiw	s0,s0,1
 7e8:	a19ff06f          	j	200 <read_srec+0x78>
 7ec:	00015783          	lhu	a5,0(sp)
 7f0:	00200713          	li	a4,2
 7f4:	0087da1b          	srliw	s4,a5,0x8
 7f8:	0087961b          	slliw	a2,a5,0x8
 7fc:	01466633          	or	a2,a2,s4
 800:	03061613          	slli	a2,a2,0x30
 804:	03065613          	srli	a2,a2,0x30
 808:	e6d750e3          	bge	a4,a3,668 <read_srec+0x4e0>
 80c:	ffc9899b          	addiw	s3,s3,-4
 810:	02099993          	slli	s3,s3,0x20
 814:	0209d993          	srli	s3,s3,0x20
 818:	00010793          	mv	a5,sp
 81c:	00110713          	addi	a4,sp,1
 820:	00100a13          	li	s4,1
 824:	00e989b3          	add	s3,s3,a4
 828:	40f60633          	sub	a2,a2,a5
 82c:	03ca1a13          	slli	s4,s4,0x3c
 830:	00f60733          	add	a4,a2,a5
 834:	0027c683          	lbu	a3,2(a5)
 838:	01476733          	or	a4,a4,s4
 83c:	00d70023          	sb	a3,0(a4)
 840:	00178793          	addi	a5,a5,1
 844:	ff3796e3          	bne	a5,s3,830 <read_srec+0x6a8>
 848:	0014041b          	addiw	s0,s0,1
 84c:	9b5ff06f          	j	200 <read_srec+0x78>
 850:	00098793          	mv	a5,s3
 854:	dd9ff06f          	j	62c <read_srec+0x4a4>
 858:	00098793          	mv	a5,s3
 85c:	00000713          	li	a4,0
 860:	c6dff06f          	j	4cc <read_srec+0x344>
 864:	fff00513          	li	a0,-1
 868:	e41ff06f          	j	6a8 <read_srec+0x520>
 86c:	00200513          	li	a0,2
 870:	e39ff06f          	j	6a8 <read_srec+0x520>
 874:	00300513          	li	a0,3
 878:	e31ff06f          	j	6a8 <read_srec+0x520>

Disassembly of section .rodata:

000000000000087c <__DATA_BEGIN__-0x684>:
 87c:	07ec                	addi	a1,sp,972
 87e:	0000                	unimp
 880:	0784                	addi	s1,sp,960
 882:	0000                	unimp
 884:	070c                	addi	a1,sp,896
 886:	0000                	unimp
 888:	0668                	addi	a0,sp,780
 88a:	0000                	unimp
 88c:	0654                	addi	a3,sp,772
 88e:	0000                	unimp
 890:	0668                	addi	a0,sp,780
 892:	0000                	unimp
 894:	06f0                	addi	a2,sp,844
 896:	0000                	unimp
 898:	06d0                	addi	a2,sp,836
 89a:	0000                	unimp
 89c:	067c                	addi	a5,sp,780
	...

Disassembly of section .sdata:

0000000000000f00 <__SDATA_BEGIN__>:
 f00:	7f7f                	0x7f7f
 f02:	7f7f                	0x7f7f
 f04:	7f7f                	0x7f7f
 f06:	7f7f                	0x7f7f
 f08:	8080                	0x8080
 f0a:	8080                	0x8080
 f0c:	8080                	0x8080
 f0e:	8080                	0x8080

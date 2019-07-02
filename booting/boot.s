
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
  0 .text         000007f0  0000000000000000  0000000000000000  00001000  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .rodata       00000024  00000000000007f0  00000000000007f0  000017f0  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .sdata        00000010  0000000000000f00  0000000000000f00  00001f00  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
SYMBOL TABLE:
0000000000000000 l    d  .text	0000000000000000 .text
00000000000007f0 l    d  .rodata	0000000000000000 .rodata
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
0000000000000000 g     F .text	0000000000000038 _start
0000000000000094 g     F .text	0000000000000014 write_uart
0000000000000100 g     F .text	00000000000006f0 read_srec
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
  24:	0dc000ef          	jal	ra,100 <read_srec>
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

0000000000000100 <read_srec>:
 100:	fff00893          	li	a7,-1
 104:	03f89893          	slli	a7,a7,0x3f
 108:	f7010113          	addi	sp,sp,-144
 10c:	00188e93          	addi	t4,a7,1
 110:	000e8303          	lb	t1,0(t4)
 114:	0ff37313          	andi	t1,t1,255
 118:	08913023          	sd	s1,128(sp)
 11c:	07213c23          	sd	s2,120(sp)
 120:	fcf30f9b          	addiw	t6,t1,-49
 124:	00001937          	lui	s2,0x1
 128:	000014b7          	lui	s1,0x1
 12c:	fc930f1b          	addiw	t5,t1,-55
 130:	0fffff93          	andi	t6,t6,255
 134:	f0093803          	ld	a6,-256(s2) # f00 <__DATA_BEGIN__>
 138:	f084be03          	ld	t3,-248(s1) # f08 <__DATA_BEGIN__+0x8>
 13c:	0fff7f13          	andi	t5,t5,255
 140:	002f9293          	slli	t0,t6,0x2
 144:	7f000793          	li	a5,2032
 148:	08813423          	sd	s0,136(sp)
 14c:	07313823          	sd	s3,112(sp)
 150:	07413423          	sd	s4,104(sp)
 154:	07513023          	sd	s5,96(sp)
 158:	05613c23          	sd	s6,88(sp)
 15c:	05713823          	sd	s7,80(sp)
 160:	00100413          	li	s0,1
 164:	00030393          	mv	t2,t1
 168:	00030593          	mv	a1,t1
 16c:	000f0513          	mv	a0,t5
 170:	00f282b3          	add	t0,t0,a5
 174:	00388793          	addi	a5,a7,3
 178:	000e8703          	lb	a4,0(t4)
 17c:	00078783          	lb	a5,0(a5)
 180:	0ff77713          	andi	a4,a4,255
 184:	0ff7f793          	andi	a5,a5,255
 188:	05300693          	li	a3,83
 18c:	00079463          	bnez	a5,194 <read_srec+0x94>
 190:	0000006f          	j	190 <read_srec+0x90>
 194:	fed71ce3          	bne	a4,a3,18c <read_srec+0x8c>
 198:	00388793          	addi	a5,a7,3
 19c:	00078783          	lb	a5,0(a5)
 1a0:	0ff7f793          	andi	a5,a5,255
 1a4:	00079463          	bnez	a5,1ac <read_srec+0xac>
 1a8:	0000006f          	j	1a8 <read_srec+0xa8>
 1ac:	fd03079b          	addiw	a5,t1,-48
 1b0:	0ff7f793          	andi	a5,a5,255
 1b4:	00900713          	li	a4,9
 1b8:	62f76063          	bltu	a4,a5,7d8 <read_srec+0x6d8>
 1bc:	03900793          	li	a5,57
 1c0:	000f0713          	mv	a4,t5
 1c4:	0077e663          	bltu	a5,t2,1d0 <read_srec+0xd0>
 1c8:	fd03871b          	addiw	a4,t2,-48
 1cc:	0ff77713          	andi	a4,a4,255
 1d0:	00388793          	addi	a5,a7,3
 1d4:	00e10023          	sb	a4,0(sp)
 1d8:	00078783          	lb	a5,0(a5)
 1dc:	0ff7f793          	andi	a5,a5,255
 1e0:	00079463          	bnez	a5,1e8 <read_srec+0xe8>
 1e4:	0000006f          	j	1e4 <read_srec+0xe4>
 1e8:	000e8783          	lb	a5,0(t4)
 1ec:	03900693          	li	a3,57
 1f0:	0ff7f793          	andi	a5,a5,255
 1f4:	3ef6e863          	bltu	a3,a5,5e4 <read_srec+0x4e4>
 1f8:	fd07879b          	addiw	a5,a5,-48
 1fc:	0ff7f793          	andi	a5,a5,255
 200:	00471993          	slli	s3,a4,0x4
 204:	0137e9b3          	or	s3,a5,s3
 208:	0019999b          	slliw	s3,s3,0x1
 20c:	00f100a3          	sb	a5,1(sp)
 210:	0ff9f993          	andi	s3,s3,255
 214:	08098863          	beqz	s3,2a4 <read_srec+0x1a4>
 218:	fff98a1b          	addiw	s4,s3,-1
 21c:	020a1a93          	slli	s5,s4,0x20
 220:	00110693          	addi	a3,sp,1
 224:	00010713          	mv	a4,sp
 228:	020ada93          	srli	s5,s5,0x20
 22c:	fd058b9b          	addiw	s7,a1,-48
 230:	00388793          	addi	a5,a7,3
 234:	01568ab3          	add	s5,a3,s5
 238:	00078783          	lb	a5,0(a5)
 23c:	00070693          	mv	a3,a4
 240:	0ff7f793          	andi	a5,a5,255
 244:	03900b13          	li	s6,57
 248:	0ffbfb93          	andi	s7,s7,255
 24c:	00079463          	bnez	a5,254 <read_srec+0x154>
 250:	0000006f          	j	250 <read_srec+0x150>
 254:	00050613          	mv	a2,a0
 258:	00bb6463          	bltu	s6,a1,260 <read_srec+0x160>
 25c:	000b8613          	mv	a2,s7
 260:	00c68023          	sb	a2,0(a3)
 264:	00168693          	addi	a3,a3,1
 268:	ff5692e3          	bne	a3,s5,24c <read_srec+0x14c>
 26c:	001a5a1b          	srliw	s4,s4,0x1
 270:	001a1a13          	slli	s4,s4,0x1
 274:	00270693          	addi	a3,a4,2
 278:	00da0a33          	add	s4,s4,a3
 27c:	0080006f          	j	284 <read_srec+0x184>
 280:	00268693          	addi	a3,a3,2
 284:	00074603          	lbu	a2,0(a4)
 288:	00174783          	lbu	a5,1(a4)
 28c:	0046161b          	slliw	a2,a2,0x4
 290:	00f7f793          	andi	a5,a5,15
 294:	00c7e7b3          	or	a5,a5,a2
 298:	00f70023          	sb	a5,0(a4)
 29c:	00068713          	mv	a4,a3
 2a0:	ff4690e3          	bne	a3,s4,280 <read_srec+0x180>
 2a4:	0019d993          	srli	s3,s3,0x1
 2a8:	0009861b          	sext.w	a2,s3
 2ac:	fff6071b          	addiw	a4,a2,-1
 2b0:	0007069b          	sext.w	a3,a4
 2b4:	50d05863          	blez	a3,7c4 <read_srec+0x6c4>
 2b8:	ffe6079b          	addiw	a5,a2,-2
 2bc:	00c00a13          	li	s4,12
 2c0:	50fa7663          	bgeu	s4,a5,7cc <read_srec+0x6cc>
 2c4:	0037571b          	srliw	a4,a4,0x3
 2c8:	00100a13          	li	s4,1
 2cc:	00013783          	ld	a5,0(sp)
 2d0:	13470263          	beq	a4,s4,3f4 <read_srec+0x2f4>
 2d4:	00813a03          	ld	s4,8(sp)
 2d8:	0107fab3          	and	s5,a5,a6
 2dc:	00200b13          	li	s6,2
 2e0:	0147c7b3          	xor	a5,a5,s4
 2e4:	010a7a33          	and	s4,s4,a6
 2e8:	014a8a33          	add	s4,s5,s4
 2ec:	01c7f7b3          	and	a5,a5,t3
 2f0:	00fa47b3          	xor	a5,s4,a5
 2f4:	11670063          	beq	a4,s6,3f4 <read_srec+0x2f4>
 2f8:	01013a03          	ld	s4,16(sp)
 2fc:	0107fb33          	and	s6,a5,a6
 300:	00300a93          	li	s5,3
 304:	00fa47b3          	xor	a5,s4,a5
 308:	010a7a33          	and	s4,s4,a6
 30c:	016a0a33          	add	s4,s4,s6
 310:	01c7f7b3          	and	a5,a5,t3
 314:	00fa47b3          	xor	a5,s4,a5
 318:	0d570e63          	beq	a4,s5,3f4 <read_srec+0x2f4>
 31c:	01813a03          	ld	s4,24(sp)
 320:	0107fab3          	and	s5,a5,a6
 324:	00400b13          	li	s6,4
 328:	00fa47b3          	xor	a5,s4,a5
 32c:	010a7a33          	and	s4,s4,a6
 330:	014a8a33          	add	s4,s5,s4
 334:	01c7f7b3          	and	a5,a5,t3
 338:	00fa47b3          	xor	a5,s4,a5
 33c:	0b670c63          	beq	a4,s6,3f4 <read_srec+0x2f4>
 340:	02013a03          	ld	s4,32(sp)
 344:	0107fab3          	and	s5,a5,a6
 348:	00500b13          	li	s6,5
 34c:	0147c7b3          	xor	a5,a5,s4
 350:	010a7a33          	and	s4,s4,a6
 354:	014a8a33          	add	s4,s5,s4
 358:	01c7f7b3          	and	a5,a5,t3
 35c:	00fa47b3          	xor	a5,s4,a5
 360:	09670a63          	beq	a4,s6,3f4 <read_srec+0x2f4>
 364:	02813a03          	ld	s4,40(sp)
 368:	0107fab3          	and	s5,a5,a6
 36c:	00600b13          	li	s6,6
 370:	0147c7b3          	xor	a5,a5,s4
 374:	010a7a33          	and	s4,s4,a6
 378:	014a8a33          	add	s4,s5,s4
 37c:	01c7f7b3          	and	a5,a5,t3
 380:	00fa47b3          	xor	a5,s4,a5
 384:	07670863          	beq	a4,s6,3f4 <read_srec+0x2f4>
 388:	03013a03          	ld	s4,48(sp)
 38c:	0107fab3          	and	s5,a5,a6
 390:	00700b13          	li	s6,7
 394:	0147c7b3          	xor	a5,a5,s4
 398:	010a7a33          	and	s4,s4,a6
 39c:	014a8a33          	add	s4,s5,s4
 3a0:	01c7f7b3          	and	a5,a5,t3
 3a4:	00fa47b3          	xor	a5,s4,a5
 3a8:	05670663          	beq	a4,s6,3f4 <read_srec+0x2f4>
 3ac:	03813a03          	ld	s4,56(sp)
 3b0:	0107fab3          	and	s5,a5,a6
 3b4:	00800b13          	li	s6,8
 3b8:	0147c7b3          	xor	a5,a5,s4
 3bc:	010a7a33          	and	s4,s4,a6
 3c0:	014a8a33          	add	s4,s5,s4
 3c4:	01c7f7b3          	and	a5,a5,t3
 3c8:	00fa47b3          	xor	a5,s4,a5
 3cc:	03670463          	beq	a4,s6,3f4 <read_srec+0x2f4>
 3d0:	04013703          	ld	a4,64(sp)
 3d4:	f0093a83          	ld	s5,-256(s2)
 3d8:	f084bb03          	ld	s6,-248(s1)
 3dc:	00e7ca33          	xor	s4,a5,a4
 3e0:	0157f7b3          	and	a5,a5,s5
 3e4:	01577733          	and	a4,a4,s5
 3e8:	00e78733          	add	a4,a5,a4
 3ec:	016a77b3          	and	a5,s4,s6
 3f0:	00f747b3          	xor	a5,a4,a5
 3f4:	0087d713          	srli	a4,a5,0x8
 3f8:	00f7073b          	addw	a4,a4,a5
 3fc:	0107da13          	srli	s4,a5,0x10
 400:	0137073b          	addw	a4,a4,s3
 404:	0147073b          	addw	a4,a4,s4
 408:	0187da13          	srli	s4,a5,0x18
 40c:	0147073b          	addw	a4,a4,s4
 410:	0207da13          	srli	s4,a5,0x20
 414:	0147073b          	addw	a4,a4,s4
 418:	0287da13          	srli	s4,a5,0x28
 41c:	0147073b          	addw	a4,a4,s4
 420:	0307da13          	srli	s4,a5,0x30
 424:	0147073b          	addw	a4,a4,s4
 428:	0387d793          	srli	a5,a5,0x38
 42c:	00f707bb          	addw	a5,a4,a5
 430:	ff86fa13          	andi	s4,a3,-8
 434:	0ff7f793          	andi	a5,a5,255
 438:	000a071b          	sext.w	a4,s4
 43c:	17468263          	beq	a3,s4,5a0 <read_srec+0x4a0>
 440:	05010a13          	addi	s4,sp,80
 444:	00ea0a33          	add	s4,s4,a4
 448:	fb0a4a83          	lbu	s5,-80(s4)
 44c:	00170a1b          	addiw	s4,a4,1
 450:	00fa87bb          	addw	a5,s5,a5
 454:	0ff7f793          	andi	a5,a5,255
 458:	14da5463          	bge	s4,a3,5a0 <read_srec+0x4a0>
 45c:	05010a93          	addi	s5,sp,80
 460:	014a8a33          	add	s4,s5,s4
 464:	fb0a4a83          	lbu	s5,-80(s4)
 468:	00270a1b          	addiw	s4,a4,2
 46c:	00fa87bb          	addw	a5,s5,a5
 470:	0ff7f793          	andi	a5,a5,255
 474:	12da5663          	bge	s4,a3,5a0 <read_srec+0x4a0>
 478:	05010a93          	addi	s5,sp,80
 47c:	014a8a33          	add	s4,s5,s4
 480:	fb0a4a83          	lbu	s5,-80(s4)
 484:	00370a1b          	addiw	s4,a4,3
 488:	00fa87bb          	addw	a5,s5,a5
 48c:	0ff7f793          	andi	a5,a5,255
 490:	10da5863          	bge	s4,a3,5a0 <read_srec+0x4a0>
 494:	05010a93          	addi	s5,sp,80
 498:	014a8a33          	add	s4,s5,s4
 49c:	fb0a4a83          	lbu	s5,-80(s4)
 4a0:	00470a1b          	addiw	s4,a4,4
 4a4:	00fa87bb          	addw	a5,s5,a5
 4a8:	0ff7f793          	andi	a5,a5,255
 4ac:	0eda5a63          	bge	s4,a3,5a0 <read_srec+0x4a0>
 4b0:	05010a93          	addi	s5,sp,80
 4b4:	014a8a33          	add	s4,s5,s4
 4b8:	fb0a4a83          	lbu	s5,-80(s4)
 4bc:	00570a1b          	addiw	s4,a4,5
 4c0:	00fa87bb          	addw	a5,s5,a5
 4c4:	0ff7f793          	andi	a5,a5,255
 4c8:	0cda5c63          	bge	s4,a3,5a0 <read_srec+0x4a0>
 4cc:	05010a93          	addi	s5,sp,80
 4d0:	014a8a33          	add	s4,s5,s4
 4d4:	fb0a4a83          	lbu	s5,-80(s4)
 4d8:	00670a1b          	addiw	s4,a4,6
 4dc:	00fa87bb          	addw	a5,s5,a5
 4e0:	0ff7f793          	andi	a5,a5,255
 4e4:	0ada5e63          	bge	s4,a3,5a0 <read_srec+0x4a0>
 4e8:	05010a93          	addi	s5,sp,80
 4ec:	014a8a33          	add	s4,s5,s4
 4f0:	fb0a4a83          	lbu	s5,-80(s4)
 4f4:	00770a1b          	addiw	s4,a4,7
 4f8:	00fa87bb          	addw	a5,s5,a5
 4fc:	0ff7f793          	andi	a5,a5,255
 500:	0ada5063          	bge	s4,a3,5a0 <read_srec+0x4a0>
 504:	05010a93          	addi	s5,sp,80
 508:	014a8a33          	add	s4,s5,s4
 50c:	fb0a4a83          	lbu	s5,-80(s4)
 510:	00870a1b          	addiw	s4,a4,8
 514:	00fa87bb          	addw	a5,s5,a5
 518:	0ff7f793          	andi	a5,a5,255
 51c:	08da5263          	bge	s4,a3,5a0 <read_srec+0x4a0>
 520:	05010a93          	addi	s5,sp,80
 524:	014a8a33          	add	s4,s5,s4
 528:	fb0a4a83          	lbu	s5,-80(s4)
 52c:	00970a1b          	addiw	s4,a4,9
 530:	00fa87bb          	addw	a5,s5,a5
 534:	0ff7f793          	andi	a5,a5,255
 538:	06da5463          	bge	s4,a3,5a0 <read_srec+0x4a0>
 53c:	05010a93          	addi	s5,sp,80
 540:	014a8a33          	add	s4,s5,s4
 544:	fb0a4a83          	lbu	s5,-80(s4)
 548:	00a70a1b          	addiw	s4,a4,10
 54c:	00fa87bb          	addw	a5,s5,a5
 550:	0ff7f793          	andi	a5,a5,255
 554:	04da5663          	bge	s4,a3,5a0 <read_srec+0x4a0>
 558:	05010a93          	addi	s5,sp,80
 55c:	014a8a33          	add	s4,s5,s4
 560:	fb0a4a83          	lbu	s5,-80(s4)
 564:	00b70a1b          	addiw	s4,a4,11
 568:	00fa87bb          	addw	a5,s5,a5
 56c:	0ff7f793          	andi	a5,a5,255
 570:	02da5863          	bge	s4,a3,5a0 <read_srec+0x4a0>
 574:	05010a93          	addi	s5,sp,80
 578:	014a8a33          	add	s4,s5,s4
 57c:	fb0a4a03          	lbu	s4,-80(s4)
 580:	00c7071b          	addiw	a4,a4,12
 584:	00fa07bb          	addw	a5,s4,a5
 588:	0ff7f793          	andi	a5,a5,255
 58c:	00d75a63          	bge	a4,a3,5a0 <read_srec+0x4a0>
 590:	00ea8733          	add	a4,s5,a4
 594:	fb074703          	lbu	a4,-80(a4)
 598:	00f707bb          	addw	a5,a4,a5
 59c:	0ff7f793          	andi	a5,a5,255
 5a0:	05010713          	addi	a4,sp,80
 5a4:	00c70633          	add	a2,a4,a2
 5a8:	fb064703          	lbu	a4,-80(a2)
 5ac:	fff74713          	not	a4,a4
 5b0:	0ff77713          	andi	a4,a4,255
 5b4:	22f71663          	bne	a4,a5,7e0 <read_srec+0x6e0>
 5b8:	00800793          	li	a5,8
 5bc:	03f7e063          	bltu	a5,t6,5dc <read_srec+0x4dc>
 5c0:	0002a783          	lw	a5,0(t0)
 5c4:	00078067          	jr	a5
 5c8:	00014703          	lbu	a4,0(sp)
 5cc:	00114683          	lbu	a3,1(sp)
 5d0:	ffe4079b          	addiw	a5,s0,-2
 5d4:	00d70733          	add	a4,a4,a3
 5d8:	20f71863          	bne	a4,a5,7e8 <read_srec+0x6e8>
 5dc:	0014041b          	addiw	s0,s0,1
 5e0:	b95ff06f          	j	174 <read_srec+0x74>
 5e4:	fc97879b          	addiw	a5,a5,-55
 5e8:	0ff7f793          	andi	a5,a5,255
 5ec:	c15ff06f          	j	200 <read_srec+0x100>
 5f0:	00014503          	lbu	a0,0(sp)
 5f4:	00114703          	lbu	a4,1(sp)
 5f8:	00314683          	lbu	a3,3(sp)
 5fc:	00214783          	lbu	a5,2(sp)
 600:	0185151b          	slliw	a0,a0,0x18
 604:	0107171b          	slliw	a4,a4,0x10
 608:	00e56533          	or	a0,a0,a4
 60c:	00d56533          	or	a0,a0,a3
 610:	0087979b          	slliw	a5,a5,0x8
 614:	00f56533          	or	a0,a0,a5
 618:	0005051b          	sext.w	a0,a0
 61c:	08813403          	ld	s0,136(sp)
 620:	08013483          	ld	s1,128(sp)
 624:	07813903          	ld	s2,120(sp)
 628:	07013983          	ld	s3,112(sp)
 62c:	06813a03          	ld	s4,104(sp)
 630:	06013a83          	ld	s5,96(sp)
 634:	05813b03          	ld	s6,88(sp)
 638:	05013b83          	ld	s7,80(sp)
 63c:	09010113          	addi	sp,sp,144
 640:	00008067          	ret
 644:	00014503          	lbu	a0,0(sp)
 648:	00114783          	lbu	a5,1(sp)
 64c:	00214703          	lbu	a4,2(sp)
 650:	0105151b          	slliw	a0,a0,0x10
 654:	0087979b          	slliw	a5,a5,0x8
 658:	00f56533          	or	a0,a0,a5
 65c:	00e56533          	or	a0,a0,a4
 660:	fbdff06f          	j	61c <read_srec+0x51c>
 664:	00015783          	lhu	a5,0(sp)
 668:	0087d71b          	srliw	a4,a5,0x8
 66c:	0087951b          	slliw	a0,a5,0x8
 670:	00e56533          	or	a0,a0,a4
 674:	03051513          	slli	a0,a0,0x30
 678:	03055513          	srli	a0,a0,0x30
 67c:	fa1ff06f          	j	61c <read_srec+0x51c>
 680:	00014603          	lbu	a2,0(sp)
 684:	00114703          	lbu	a4,1(sp)
 688:	00314a03          	lbu	s4,3(sp)
 68c:	00214783          	lbu	a5,2(sp)
 690:	0186161b          	slliw	a2,a2,0x18
 694:	0107171b          	slliw	a4,a4,0x10
 698:	00e66633          	or	a2,a2,a4
 69c:	0087979b          	slliw	a5,a5,0x8
 6a0:	01466633          	or	a2,a2,s4
 6a4:	00f66633          	or	a2,a2,a5
 6a8:	00400793          	li	a5,4
 6ac:	0006061b          	sext.w	a2,a2
 6b0:	f2d7d6e3          	bge	a5,a3,5dc <read_srec+0x4dc>
 6b4:	ffa9871b          	addiw	a4,s3,-6
 6b8:	02071713          	slli	a4,a4,0x20
 6bc:	02075713          	srli	a4,a4,0x20
 6c0:	00010793          	mv	a5,sp
 6c4:	00110693          	addi	a3,sp,1
 6c8:	00100a13          	li	s4,1
 6cc:	00d70733          	add	a4,a4,a3
 6d0:	40f60633          	sub	a2,a2,a5
 6d4:	03ca1a13          	slli	s4,s4,0x3c
 6d8:	00f606b3          	add	a3,a2,a5
 6dc:	0047c983          	lbu	s3,4(a5)
 6e0:	0146e6b3          	or	a3,a3,s4
 6e4:	01368023          	sb	s3,0(a3)
 6e8:	00178793          	addi	a5,a5,1
 6ec:	fee796e3          	bne	a5,a4,6d8 <read_srec+0x5d8>
 6f0:	0014041b          	addiw	s0,s0,1
 6f4:	a81ff06f          	j	174 <read_srec+0x74>
 6f8:	00014603          	lbu	a2,0(sp)
 6fc:	00114783          	lbu	a5,1(sp)
 700:	00214703          	lbu	a4,2(sp)
 704:	0106161b          	slliw	a2,a2,0x10
 708:	0087979b          	slliw	a5,a5,0x8
 70c:	00f66633          	or	a2,a2,a5
 710:	00300793          	li	a5,3
 714:	00e66633          	or	a2,a2,a4
 718:	ecd7d2e3          	bge	a5,a3,5dc <read_srec+0x4dc>
 71c:	ffb9899b          	addiw	s3,s3,-5
 720:	02099993          	slli	s3,s3,0x20
 724:	0209d993          	srli	s3,s3,0x20
 728:	00010793          	mv	a5,sp
 72c:	00110713          	addi	a4,sp,1
 730:	00100a13          	li	s4,1
 734:	00e989b3          	add	s3,s3,a4
 738:	40f60633          	sub	a2,a2,a5
 73c:	03ca1a13          	slli	s4,s4,0x3c
 740:	00f60733          	add	a4,a2,a5
 744:	0037c683          	lbu	a3,3(a5)
 748:	01476733          	or	a4,a4,s4
 74c:	00d70023          	sb	a3,0(a4)
 750:	00178793          	addi	a5,a5,1
 754:	ff3796e3          	bne	a5,s3,740 <read_srec+0x640>
 758:	0014041b          	addiw	s0,s0,1
 75c:	a19ff06f          	j	174 <read_srec+0x74>
 760:	00015783          	lhu	a5,0(sp)
 764:	00200713          	li	a4,2
 768:	0087da1b          	srliw	s4,a5,0x8
 76c:	0087961b          	slliw	a2,a5,0x8
 770:	01466633          	or	a2,a2,s4
 774:	03061613          	slli	a2,a2,0x30
 778:	03065613          	srli	a2,a2,0x30
 77c:	e6d750e3          	bge	a4,a3,5dc <read_srec+0x4dc>
 780:	ffc9899b          	addiw	s3,s3,-4
 784:	02099993          	slli	s3,s3,0x20
 788:	0209d993          	srli	s3,s3,0x20
 78c:	00010793          	mv	a5,sp
 790:	00110713          	addi	a4,sp,1
 794:	00100a13          	li	s4,1
 798:	00e989b3          	add	s3,s3,a4
 79c:	40f60633          	sub	a2,a2,a5
 7a0:	03ca1a13          	slli	s4,s4,0x3c
 7a4:	00f60733          	add	a4,a2,a5
 7a8:	0027c683          	lbu	a3,2(a5)
 7ac:	01476733          	or	a4,a4,s4
 7b0:	00d70023          	sb	a3,0(a4)
 7b4:	00178793          	addi	a5,a5,1
 7b8:	ff3796e3          	bne	a5,s3,7a4 <read_srec+0x6a4>
 7bc:	0014041b          	addiw	s0,s0,1
 7c0:	9b5ff06f          	j	174 <read_srec+0x74>
 7c4:	00098793          	mv	a5,s3
 7c8:	dd9ff06f          	j	5a0 <read_srec+0x4a0>
 7cc:	00098793          	mv	a5,s3
 7d0:	00000713          	li	a4,0
 7d4:	c6dff06f          	j	440 <read_srec+0x340>
 7d8:	fff00513          	li	a0,-1
 7dc:	e41ff06f          	j	61c <read_srec+0x51c>
 7e0:	00200513          	li	a0,2
 7e4:	e39ff06f          	j	61c <read_srec+0x51c>
 7e8:	00300513          	li	a0,3
 7ec:	e31ff06f          	j	61c <read_srec+0x51c>

Disassembly of section .rodata:

00000000000007f0 <__DATA_BEGIN__-0x710>:
 7f0:	0760                	addi	s0,sp,908
 7f2:	0000                	unimp
 7f4:	06f8                	addi	a4,sp,844
 7f6:	0000                	unimp
 7f8:	0680                	addi	s0,sp,832
 7fa:	0000                	unimp
 7fc:	05dc                	addi	a5,sp,708
 7fe:	0000                	unimp
 800:	05c8                	addi	a0,sp,708
 802:	0000                	unimp
 804:	05dc                	addi	a5,sp,708
 806:	0000                	unimp
 808:	0664                	addi	s1,sp,780
 80a:	0000                	unimp
 80c:	0644                	addi	s1,sp,772
 80e:	0000                	unimp
 810:	05f0                	addi	a2,sp,716
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


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
  0 .text         000008a0  0000000000000000  0000000000000000  00001000  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .rodata       00000038  00000000000008a0  00000000000008a0  000018a0  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .sdata        00000010  0000000000000f00  0000000000000f00  00001f00  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
SYMBOL TABLE:
0000000000000000 l    d  .text	0000000000000000 .text
00000000000008a0 l    d  .rodata	0000000000000000 .rodata
0000000000000f00 l    d  .sdata	0000000000000000 .sdata
0000000000000000 l    df *ABS*	0000000000000000 boot_rom.s
1000000000000000 l       *ABS*	0000000000000000 MEM_START
100000000000f000 l       *ABS*	0000000000000000 SP_START
000000000000000c l       .text	0000000000000000 init
0000000000000028 l       .text	0000000000000000 final
0000000000000000 l    df *ABS*	0000000000000000 RVonFPGA_boot_funcs.c
0000000000001700 g       *ABS*	0000000000000000 __global_pointer$
0000000000000060 g     F .text	0000000000000028 read_uart
0000000000000f00 g       .sdata	0000000000000000 __SDATA_BEGIN__
00000000000000f4 g     F .text	00000000000000cc led_sw_uart_test
0000000000000030 g     F .text	0000000000000018 uart_stb_in
000000000000009c g     F .text	0000000000000014 write_led_lo
00000000000000b0 g     F .text	0000000000000014 write_led_hi
0000000000000000 g     F .text	0000000000000030 _start
0000000000000088 g     F .text	0000000000000014 write_uart
00000000000001c0 g     F .text	00000000000006e0 read_srec
0000000000000f10 g       .sdata	0000000000000000 __BSS_END__
0000000000000f10 g       .sdata	0000000000000000 __bss_start
0000000000000f00 g       .rodata	0000000000000000 __DATA_BEGIN__
0000000000000f10 g       .sdata	0000000000000000 _edata
0000000000000f10 g       .sdata	0000000000000000 _end
00000000000000dc g     F .text	0000000000000018 read_sw_hi
00000000000000c4 g     F .text	0000000000000018 read_sw_lo
0000000000000048 g     F .text	0000000000000018 uart_stb_out



Disassembly of section .text:

0000000000000000 <_start>:
   0:	00000513          	li	a0,0
   4:	0ac000ef          	jal	ra,b0 <write_led_hi>
   8:	094000ef          	jal	ra,9c <write_led_lo>

000000000000000c <init>:
   c:	0010011b          	addiw	sp,zero,1
  10:	03011113          	slli	sp,sp,0x30
  14:	00f10113          	addi	sp,sp,15
  18:	00c11113          	slli	sp,sp,0xc
  1c:	00001197          	auipc	gp,0x1
  20:	6e418193          	addi	gp,gp,1764 # 1700 <__global_pointer$>
  24:	0d0000ef          	jal	ra,f4 <led_sw_uart_test>

0000000000000028 <final>:
  28:	198000ef          	jal	ra,1c0 <read_srec>
  2c:	00050067          	jr	a0

0000000000000030 <uart_stb_in>:
  30:	fff00513          	li	a0,-1
  34:	03f51513          	slli	a0,a0,0x3f
  38:	00350513          	addi	a0,a0,3
  3c:	00050503          	lb	a0,0(a0)
  40:	0ff57513          	andi	a0,a0,255
  44:	00008067          	ret

0000000000000048 <uart_stb_out>:
  48:	fff00513          	li	a0,-1
  4c:	03f51513          	slli	a0,a0,0x3f
  50:	00250513          	addi	a0,a0,2
  54:	00050503          	lb	a0,0(a0)
  58:	0ff57513          	andi	a0,a0,255
  5c:	00008067          	ret

0000000000000060 <read_uart>:
  60:	fff00513          	li	a0,-1
  64:	03f51513          	slli	a0,a0,0x3f
  68:	00350713          	addi	a4,a0,3
  6c:	00070783          	lb	a5,0(a4)
  70:	0ff7f793          	andi	a5,a5,255
  74:	fe078ce3          	beqz	a5,6c <read_uart+0xc>
  78:	00150513          	addi	a0,a0,1
  7c:	00050503          	lb	a0,0(a0)
  80:	0ff57513          	andi	a0,a0,255
  84:	00008067          	ret

0000000000000088 <write_uart>:
  88:	fff00793          	li	a5,-1
  8c:	03f79793          	slli	a5,a5,0x3f
  90:	00178793          	addi	a5,a5,1
  94:	00a78023          	sb	a0,0(a5)
  98:	00008067          	ret

000000000000009c <write_led_lo>:
  9c:	fff00793          	li	a5,-1
  a0:	03f79793          	slli	a5,a5,0x3f
  a4:	00478793          	addi	a5,a5,4
  a8:	00a78023          	sb	a0,0(a5)
  ac:	00008067          	ret

00000000000000b0 <write_led_hi>:
  b0:	fff00793          	li	a5,-1
  b4:	03f79793          	slli	a5,a5,0x3f
  b8:	00578793          	addi	a5,a5,5
  bc:	00a78023          	sb	a0,0(a5)
  c0:	00008067          	ret

00000000000000c4 <read_sw_lo>:
  c4:	fff00513          	li	a0,-1
  c8:	03f51513          	slli	a0,a0,0x3f
  cc:	00450513          	addi	a0,a0,4
  d0:	00050503          	lb	a0,0(a0)
  d4:	0ff57513          	andi	a0,a0,255
  d8:	00008067          	ret

00000000000000dc <read_sw_hi>:
  dc:	fff00513          	li	a0,-1
  e0:	03f51513          	slli	a0,a0,0x3f
  e4:	00550513          	addi	a0,a0,5
  e8:	00050503          	lb	a0,0(a0)
  ec:	0ff57513          	andi	a0,a0,255
  f0:	00008067          	ret

00000000000000f4 <led_sw_uart_test>:
  f4:	000017b7          	lui	a5,0x1
  f8:	8c878713          	addi	a4,a5,-1848 # 8c8 <read_srec+0x708>
  fc:	8c87b683          	ld	a3,-1848(a5)
 100:	00873703          	ld	a4,8(a4)
 104:	fff00793          	li	a5,-1
 108:	fe010113          	addi	sp,sp,-32
 10c:	03f79793          	slli	a5,a5,0x3f
 110:	00d13823          	sd	a3,16(sp)
 114:	00e13c23          	sd	a4,24(sp)
 118:	01010613          	addi	a2,sp,16
 11c:	01f10513          	addi	a0,sp,31
 120:	00278693          	addi	a3,a5,2
 124:	00178593          	addi	a1,a5,1
 128:	00068703          	lb	a4,0(a3)
 12c:	0ff77713          	andi	a4,a4,255
 130:	fe071ce3          	bnez	a4,128 <led_sw_uart_test+0x34>
 134:	00064703          	lbu	a4,0(a2)
 138:	00e58023          	sb	a4,0(a1)
 13c:	00160613          	addi	a2,a2,1
 140:	fea614e3          	bne	a2,a0,128 <led_sw_uart_test+0x34>
 144:	00578593          	addi	a1,a5,5
 148:	00058683          	lb	a3,0(a1)
 14c:	0ff6f693          	andi	a3,a3,255
 150:	00478793          	addi	a5,a5,4
 154:	00078703          	lb	a4,0(a5)
 158:	00869693          	slli	a3,a3,0x8
 15c:	0ff77713          	andi	a4,a4,255
 160:	00d76733          	or	a4,a4,a3
 164:	000186b7          	lui	a3,0x18
 168:	69f68693          	addi	a3,a3,1695 # 1869f <__global_pointer$+0x16f9f>
 16c:	00078613          	mv	a2,a5
 170:	00012623          	sw	zero,12(sp)
 174:	00c12783          	lw	a5,12(sp)
 178:	0007879b          	sext.w	a5,a5
 17c:	fef6cae3          	blt	a3,a5,170 <led_sw_uart_test+0x7c>
 180:	00c12783          	lw	a5,12(sp)
 184:	0007879b          	sext.w	a5,a5
 188:	00079e63          	bnez	a5,1a4 <led_sw_uart_test+0xb0>
 18c:	00e60023          	sb	a4,0(a2)
 190:	0087579b          	srliw	a5,a4,0x8
 194:	00f58023          	sb	a5,0(a1)
 198:	0017071b          	addiw	a4,a4,1
 19c:	03071713          	slli	a4,a4,0x30
 1a0:	03075713          	srli	a4,a4,0x30
 1a4:	00c12783          	lw	a5,12(sp)
 1a8:	0017879b          	addiw	a5,a5,1
 1ac:	00f12623          	sw	a5,12(sp)
 1b0:	00c12783          	lw	a5,12(sp)
 1b4:	0007879b          	sext.w	a5,a5
 1b8:	fcf6d4e3          	bge	a3,a5,180 <led_sw_uart_test+0x8c>
 1bc:	fb5ff06f          	j	170 <led_sw_uart_test+0x7c>

00000000000001c0 <read_srec>:
 1c0:	000017b7          	lui	a5,0x1
 1c4:	f007be03          	ld	t3,-256(a5) # f00 <__DATA_BEGIN__>
 1c8:	000017b7          	lui	a5,0x1
 1cc:	f087bf03          	ld	t5,-248(a5) # f08 <__DATA_BEGIN__+0x8>
 1d0:	fff00513          	li	a0,-1
 1d4:	f5010113          	addi	sp,sp,-176
 1d8:	03f51513          	slli	a0,a0,0x3f
 1dc:	00100293          	li	t0,1
 1e0:	000013b7          	lui	t2,0x1
 1e4:	0a813423          	sd	s0,168(sp)
 1e8:	0a913023          	sd	s1,160(sp)
 1ec:	09213c23          	sd	s2,152(sp)
 1f0:	09313823          	sd	s3,144(sp)
 1f4:	09413423          	sd	s4,136(sp)
 1f8:	09513023          	sd	s5,128(sp)
 1fc:	07613c23          	sd	s6,120(sp)
 200:	07713823          	sd	s7,112(sp)
 204:	00350713          	addi	a4,a0,3
 208:	07813423          	sd	s8,104(sp)
 20c:	07913023          	sd	s9,96(sp)
 210:	05a13c23          	sd	s10,88(sp)
 214:	05b13823          	sd	s11,80(sp)
 218:	00150513          	addi	a0,a0,1
 21c:	05300313          	li	t1,83
 220:	00900413          	li	s0,9
 224:	03900893          	li	a7,57
 228:	00010e93          	mv	t4,sp
 22c:	00c00493          	li	s1,12
 230:	00100913          	li	s2,1
 234:	00200993          	li	s3,2
 238:	00300a13          	li	s4,3
 23c:	00400a93          	li	s5,4
 240:	000e0b13          	mv	s6,t3
 244:	000f0b93          	mv	s7,t5
 248:	8a038393          	addi	t2,t2,-1888 # 8a0 <read_srec+0x6e0>
 24c:	03c29f93          	slli	t6,t0,0x3c
 250:	00070783          	lb	a5,0(a4)
 254:	0ff7f793          	andi	a5,a5,255
 258:	fe078ce3          	beqz	a5,250 <read_srec+0x90>
 25c:	00050783          	lb	a5,0(a0)
 260:	0ff7f793          	andi	a5,a5,255
 264:	fe6796e3          	bne	a5,t1,250 <read_srec+0x90>
 268:	00070783          	lb	a5,0(a4)
 26c:	0ff7f793          	andi	a5,a5,255
 270:	fe078ce3          	beqz	a5,268 <read_srec+0xa8>
 274:	00050c03          	lb	s8,0(a0)
 278:	0ffc7c13          	andi	s8,s8,255
 27c:	fd0c079b          	addiw	a5,s8,-48
 280:	0ff7f793          	andi	a5,a5,255
 284:	60f46663          	bltu	s0,a5,890 <read_srec+0x6d0>
 288:	00070783          	lb	a5,0(a4)
 28c:	0ff7f793          	andi	a5,a5,255
 290:	fe078ce3          	beqz	a5,288 <read_srec+0xc8>
 294:	00050783          	lb	a5,0(a0)
 298:	0ff7f793          	andi	a5,a5,255
 29c:	40f8ea63          	bltu	a7,a5,6b0 <read_srec+0x4f0>
 2a0:	fd07879b          	addiw	a5,a5,-48
 2a4:	0ff7f693          	andi	a3,a5,255
 2a8:	00d10023          	sb	a3,0(sp)
 2ac:	00070783          	lb	a5,0(a4)
 2b0:	0ff7f793          	andi	a5,a5,255
 2b4:	fe078ce3          	beqz	a5,2ac <read_srec+0xec>
 2b8:	00050783          	lb	a5,0(a0)
 2bc:	0ff7f793          	andi	a5,a5,255
 2c0:	3ef8e263          	bltu	a7,a5,6a4 <read_srec+0x4e4>
 2c4:	fd07879b          	addiw	a5,a5,-48
 2c8:	0ff7f793          	andi	a5,a5,255
 2cc:	00469593          	slli	a1,a3,0x4
 2d0:	00b7e5b3          	or	a1,a5,a1
 2d4:	0015959b          	slliw	a1,a1,0x1
 2d8:	00f100a3          	sb	a5,1(sp)
 2dc:	0ff5f593          	andi	a1,a1,255
 2e0:	08058263          	beqz	a1,364 <read_srec+0x1a4>
 2e4:	fff5881b          	addiw	a6,a1,-1
 2e8:	02081c93          	slli	s9,a6,0x20
 2ec:	020cdc93          	srli	s9,s9,0x20
 2f0:	00110793          	addi	a5,sp,1
 2f4:	000e8693          	mv	a3,t4
 2f8:	01978cb3          	add	s9,a5,s9
 2fc:	000e8613          	mv	a2,t4
 300:	00070783          	lb	a5,0(a4)
 304:	0ff7f793          	andi	a5,a5,255
 308:	fe078ce3          	beqz	a5,300 <read_srec+0x140>
 30c:	00050783          	lb	a5,0(a0)
 310:	0ff7f793          	andi	a5,a5,255
 314:	38f8e263          	bltu	a7,a5,698 <read_srec+0x4d8>
 318:	fd07879b          	addiw	a5,a5,-48
 31c:	0ff7f793          	andi	a5,a5,255
 320:	00f60023          	sb	a5,0(a2)
 324:	00160613          	addi	a2,a2,1
 328:	fd961ce3          	bne	a2,s9,300 <read_srec+0x140>
 32c:	00185c9b          	srliw	s9,a6,0x1
 330:	001c9c93          	slli	s9,s9,0x1
 334:	002e8613          	addi	a2,t4,2
 338:	00cc8cb3          	add	s9,s9,a2
 33c:	0080006f          	j	344 <read_srec+0x184>
 340:	00260613          	addi	a2,a2,2
 344:	0006c803          	lbu	a6,0(a3)
 348:	0016c783          	lbu	a5,1(a3)
 34c:	0048181b          	slliw	a6,a6,0x4
 350:	00f7f793          	andi	a5,a5,15
 354:	0107e7b3          	or	a5,a5,a6
 358:	00f68023          	sb	a5,0(a3)
 35c:	00060693          	mv	a3,a2
 360:	ff9610e3          	bne	a2,s9,340 <read_srec+0x180>
 364:	0015d593          	srli	a1,a1,0x1
 368:	0005881b          	sext.w	a6,a1
 36c:	fff8069b          	addiw	a3,a6,-1
 370:	0006861b          	sext.w	a2,a3
 374:	50c05463          	blez	a2,87c <read_srec+0x6bc>
 378:	ffe8079b          	addiw	a5,a6,-2
 37c:	50f4f463          	bgeu	s1,a5,884 <read_srec+0x6c4>
 380:	0036d69b          	srliw	a3,a3,0x3
 384:	00013783          	ld	a5,0(sp)
 388:	11268863          	beq	a3,s2,498 <read_srec+0x2d8>
 38c:	00813c83          	ld	s9,8(sp)
 390:	01c7fd33          	and	s10,a5,t3
 394:	0197c7b3          	xor	a5,a5,s9
 398:	01ccfcb3          	and	s9,s9,t3
 39c:	019d0cb3          	add	s9,s10,s9
 3a0:	01e7f7b3          	and	a5,a5,t5
 3a4:	00fcc7b3          	xor	a5,s9,a5
 3a8:	0f368863          	beq	a3,s3,498 <read_srec+0x2d8>
 3ac:	01013c83          	ld	s9,16(sp)
 3b0:	01c7fd33          	and	s10,a5,t3
 3b4:	00fcc7b3          	xor	a5,s9,a5
 3b8:	01ccfcb3          	and	s9,s9,t3
 3bc:	01ac8cb3          	add	s9,s9,s10
 3c0:	01e7f7b3          	and	a5,a5,t5
 3c4:	00fcc7b3          	xor	a5,s9,a5
 3c8:	0d468863          	beq	a3,s4,498 <read_srec+0x2d8>
 3cc:	01813c83          	ld	s9,24(sp)
 3d0:	01c7fd33          	and	s10,a5,t3
 3d4:	00fcc7b3          	xor	a5,s9,a5
 3d8:	01ccfcb3          	and	s9,s9,t3
 3dc:	019d0cb3          	add	s9,s10,s9
 3e0:	01e7f7b3          	and	a5,a5,t5
 3e4:	00fcc7b3          	xor	a5,s9,a5
 3e8:	0b568863          	beq	a3,s5,498 <read_srec+0x2d8>
 3ec:	02013c83          	ld	s9,32(sp)
 3f0:	01c7fd33          	and	s10,a5,t3
 3f4:	00500d93          	li	s11,5
 3f8:	0197c7b3          	xor	a5,a5,s9
 3fc:	01ccfcb3          	and	s9,s9,t3
 400:	019d0cb3          	add	s9,s10,s9
 404:	01e7f7b3          	and	a5,a5,t5
 408:	00fcc7b3          	xor	a5,s9,a5
 40c:	09b68663          	beq	a3,s11,498 <read_srec+0x2d8>
 410:	02813c83          	ld	s9,40(sp)
 414:	01c7fd33          	and	s10,a5,t3
 418:	00600d93          	li	s11,6
 41c:	0197c7b3          	xor	a5,a5,s9
 420:	01ccfcb3          	and	s9,s9,t3
 424:	019d0cb3          	add	s9,s10,s9
 428:	01e7f7b3          	and	a5,a5,t5
 42c:	00fcc7b3          	xor	a5,s9,a5
 430:	07b68463          	beq	a3,s11,498 <read_srec+0x2d8>
 434:	03013c83          	ld	s9,48(sp)
 438:	01c7fd33          	and	s10,a5,t3
 43c:	00700d93          	li	s11,7
 440:	0197c7b3          	xor	a5,a5,s9
 444:	01ccfcb3          	and	s9,s9,t3
 448:	019d0cb3          	add	s9,s10,s9
 44c:	01e7f7b3          	and	a5,a5,t5
 450:	00fcc7b3          	xor	a5,s9,a5
 454:	05b68263          	beq	a3,s11,498 <read_srec+0x2d8>
 458:	03813c83          	ld	s9,56(sp)
 45c:	01c7fd33          	and	s10,a5,t3
 460:	00800d93          	li	s11,8
 464:	0197c7b3          	xor	a5,a5,s9
 468:	01ccfcb3          	and	s9,s9,t3
 46c:	019d0cb3          	add	s9,s10,s9
 470:	01e7f7b3          	and	a5,a5,t5
 474:	00fcc7b3          	xor	a5,s9,a5
 478:	03b68063          	beq	a3,s11,498 <read_srec+0x2d8>
 47c:	04013683          	ld	a3,64(sp)
 480:	0167fcb3          	and	s9,a5,s6
 484:	00d7c7b3          	xor	a5,a5,a3
 488:	0166f6b3          	and	a3,a3,s6
 48c:	00dc86b3          	add	a3,s9,a3
 490:	0177f7b3          	and	a5,a5,s7
 494:	00f6c7b3          	xor	a5,a3,a5
 498:	0087d693          	srli	a3,a5,0x8
 49c:	00f686bb          	addw	a3,a3,a5
 4a0:	0107dc93          	srli	s9,a5,0x10
 4a4:	00b686bb          	addw	a3,a3,a1
 4a8:	019686bb          	addw	a3,a3,s9
 4ac:	0187dc93          	srli	s9,a5,0x18
 4b0:	019686bb          	addw	a3,a3,s9
 4b4:	0207dc93          	srli	s9,a5,0x20
 4b8:	019686bb          	addw	a3,a3,s9
 4bc:	0287dc93          	srli	s9,a5,0x28
 4c0:	019686bb          	addw	a3,a3,s9
 4c4:	0307dc93          	srli	s9,a5,0x30
 4c8:	019686bb          	addw	a3,a3,s9
 4cc:	0387d793          	srli	a5,a5,0x38
 4d0:	00f687bb          	addw	a5,a3,a5
 4d4:	ff867c93          	andi	s9,a2,-8
 4d8:	0ff7f793          	andi	a5,a5,255
 4dc:	000c869b          	sext.w	a3,s9
 4e0:	17960263          	beq	a2,s9,644 <read_srec+0x484>
 4e4:	05010c93          	addi	s9,sp,80
 4e8:	00dc8cb3          	add	s9,s9,a3
 4ec:	fb0ccd03          	lbu	s10,-80(s9)
 4f0:	00168c9b          	addiw	s9,a3,1
 4f4:	00fd07bb          	addw	a5,s10,a5
 4f8:	0ff7f793          	andi	a5,a5,255
 4fc:	14ccd463          	bge	s9,a2,644 <read_srec+0x484>
 500:	05010d13          	addi	s10,sp,80
 504:	019d0cb3          	add	s9,s10,s9
 508:	fb0ccd03          	lbu	s10,-80(s9)
 50c:	00268c9b          	addiw	s9,a3,2
 510:	00fd07bb          	addw	a5,s10,a5
 514:	0ff7f793          	andi	a5,a5,255
 518:	12ccd663          	bge	s9,a2,644 <read_srec+0x484>
 51c:	05010d13          	addi	s10,sp,80
 520:	019d0cb3          	add	s9,s10,s9
 524:	fb0ccd03          	lbu	s10,-80(s9)
 528:	00368c9b          	addiw	s9,a3,3
 52c:	00fd07bb          	addw	a5,s10,a5
 530:	0ff7f793          	andi	a5,a5,255
 534:	10ccd863          	bge	s9,a2,644 <read_srec+0x484>
 538:	05010d13          	addi	s10,sp,80
 53c:	019d0cb3          	add	s9,s10,s9
 540:	fb0ccd03          	lbu	s10,-80(s9)
 544:	00468c9b          	addiw	s9,a3,4
 548:	00fd07bb          	addw	a5,s10,a5
 54c:	0ff7f793          	andi	a5,a5,255
 550:	0eccda63          	bge	s9,a2,644 <read_srec+0x484>
 554:	05010d13          	addi	s10,sp,80
 558:	019d0cb3          	add	s9,s10,s9
 55c:	fb0ccd03          	lbu	s10,-80(s9)
 560:	00568c9b          	addiw	s9,a3,5
 564:	00fd07bb          	addw	a5,s10,a5
 568:	0ff7f793          	andi	a5,a5,255
 56c:	0cccdc63          	bge	s9,a2,644 <read_srec+0x484>
 570:	05010d13          	addi	s10,sp,80
 574:	019d0cb3          	add	s9,s10,s9
 578:	fb0ccd03          	lbu	s10,-80(s9)
 57c:	00668c9b          	addiw	s9,a3,6
 580:	00fd07bb          	addw	a5,s10,a5
 584:	0ff7f793          	andi	a5,a5,255
 588:	0accde63          	bge	s9,a2,644 <read_srec+0x484>
 58c:	05010d13          	addi	s10,sp,80
 590:	019d0cb3          	add	s9,s10,s9
 594:	fb0ccd03          	lbu	s10,-80(s9)
 598:	00768c9b          	addiw	s9,a3,7
 59c:	00fd07bb          	addw	a5,s10,a5
 5a0:	0ff7f793          	andi	a5,a5,255
 5a4:	0accd063          	bge	s9,a2,644 <read_srec+0x484>
 5a8:	05010d13          	addi	s10,sp,80
 5ac:	019d0cb3          	add	s9,s10,s9
 5b0:	fb0ccd03          	lbu	s10,-80(s9)
 5b4:	00868c9b          	addiw	s9,a3,8
 5b8:	00fd07bb          	addw	a5,s10,a5
 5bc:	0ff7f793          	andi	a5,a5,255
 5c0:	08ccd263          	bge	s9,a2,644 <read_srec+0x484>
 5c4:	05010d13          	addi	s10,sp,80
 5c8:	019d0cb3          	add	s9,s10,s9
 5cc:	fb0ccd03          	lbu	s10,-80(s9)
 5d0:	00968c9b          	addiw	s9,a3,9
 5d4:	00fd07bb          	addw	a5,s10,a5
 5d8:	0ff7f793          	andi	a5,a5,255
 5dc:	06ccd463          	bge	s9,a2,644 <read_srec+0x484>
 5e0:	05010d13          	addi	s10,sp,80
 5e4:	019d0cb3          	add	s9,s10,s9
 5e8:	fb0ccd03          	lbu	s10,-80(s9)
 5ec:	00a68c9b          	addiw	s9,a3,10
 5f0:	00fd07bb          	addw	a5,s10,a5
 5f4:	0ff7f793          	andi	a5,a5,255
 5f8:	04ccd663          	bge	s9,a2,644 <read_srec+0x484>
 5fc:	05010d13          	addi	s10,sp,80
 600:	019d0cb3          	add	s9,s10,s9
 604:	fb0ccd03          	lbu	s10,-80(s9)
 608:	00b68c9b          	addiw	s9,a3,11
 60c:	00fd07bb          	addw	a5,s10,a5
 610:	0ff7f793          	andi	a5,a5,255
 614:	02ccd863          	bge	s9,a2,644 <read_srec+0x484>
 618:	05010d13          	addi	s10,sp,80
 61c:	019d0cb3          	add	s9,s10,s9
 620:	fb0ccc83          	lbu	s9,-80(s9)
 624:	00c6869b          	addiw	a3,a3,12
 628:	00fc87bb          	addw	a5,s9,a5
 62c:	0ff7f793          	andi	a5,a5,255
 630:	00c6da63          	bge	a3,a2,644 <read_srec+0x484>
 634:	00dd06b3          	add	a3,s10,a3
 638:	fb06c683          	lbu	a3,-80(a3)
 63c:	00f687bb          	addw	a5,a3,a5
 640:	0ff7f793          	andi	a5,a5,255
 644:	05010693          	addi	a3,sp,80
 648:	01068833          	add	a6,a3,a6
 64c:	fb084683          	lbu	a3,-80(a6)
 650:	fff6c693          	not	a3,a3
 654:	0ff6f693          	andi	a3,a3,255
 658:	24f69063          	bne	a3,a5,898 <read_srec+0x6d8>
 65c:	fcfc079b          	addiw	a5,s8,-49
 660:	0ff7f793          	andi	a5,a5,255
 664:	00800693          	li	a3,8
 668:	02f6e463          	bltu	a3,a5,690 <read_srec+0x4d0>
 66c:	00279793          	slli	a5,a5,0x2
 670:	007787b3          	add	a5,a5,t2
 674:	0007a783          	lw	a5,0(a5)
 678:	00078067          	jr	a5
 67c:	00014683          	lbu	a3,0(sp)
 680:	00114603          	lbu	a2,1(sp)
 684:	ffe2879b          	addiw	a5,t0,-2
 688:	00c686b3          	add	a3,a3,a2
 68c:	20f69263          	bne	a3,a5,890 <read_srec+0x6d0>
 690:	0012829b          	addiw	t0,t0,1
 694:	bbdff06f          	j	250 <read_srec+0x90>
 698:	fc97879b          	addiw	a5,a5,-55
 69c:	0ff7f793          	andi	a5,a5,255
 6a0:	c81ff06f          	j	320 <read_srec+0x160>
 6a4:	fc97879b          	addiw	a5,a5,-55
 6a8:	0ff7f793          	andi	a5,a5,255
 6ac:	c21ff06f          	j	2cc <read_srec+0x10c>
 6b0:	fc97879b          	addiw	a5,a5,-55
 6b4:	0ff7f693          	andi	a3,a5,255
 6b8:	bf1ff06f          	j	2a8 <read_srec+0xe8>
 6bc:	00014503          	lbu	a0,0(sp)
 6c0:	00114703          	lbu	a4,1(sp)
 6c4:	00314683          	lbu	a3,3(sp)
 6c8:	00214783          	lbu	a5,2(sp)
 6cc:	0185151b          	slliw	a0,a0,0x18
 6d0:	0107171b          	slliw	a4,a4,0x10
 6d4:	00e56533          	or	a0,a0,a4
 6d8:	00d56533          	or	a0,a0,a3
 6dc:	0087979b          	slliw	a5,a5,0x8
 6e0:	00f56533          	or	a0,a0,a5
 6e4:	0005051b          	sext.w	a0,a0
 6e8:	0a813403          	ld	s0,168(sp)
 6ec:	0a013483          	ld	s1,160(sp)
 6f0:	09813903          	ld	s2,152(sp)
 6f4:	09013983          	ld	s3,144(sp)
 6f8:	08813a03          	ld	s4,136(sp)
 6fc:	08013a83          	ld	s5,128(sp)
 700:	07813b03          	ld	s6,120(sp)
 704:	07013b83          	ld	s7,112(sp)
 708:	06813c03          	ld	s8,104(sp)
 70c:	06013c83          	ld	s9,96(sp)
 710:	05813d03          	ld	s10,88(sp)
 714:	05013d83          	ld	s11,80(sp)
 718:	0b010113          	addi	sp,sp,176
 71c:	00008067          	ret
 720:	00014503          	lbu	a0,0(sp)
 724:	00114783          	lbu	a5,1(sp)
 728:	00214703          	lbu	a4,2(sp)
 72c:	0105151b          	slliw	a0,a0,0x10
 730:	0087979b          	slliw	a5,a5,0x8
 734:	00f56533          	or	a0,a0,a5
 738:	00e56533          	or	a0,a0,a4
 73c:	fadff06f          	j	6e8 <read_srec+0x528>
 740:	00015783          	lhu	a5,0(sp)
 744:	0087d71b          	srliw	a4,a5,0x8
 748:	0087951b          	slliw	a0,a5,0x8
 74c:	00e56533          	or	a0,a0,a4
 750:	03051513          	slli	a0,a0,0x30
 754:	03055513          	srli	a0,a0,0x30
 758:	f91ff06f          	j	6e8 <read_srec+0x528>
 75c:	00014803          	lbu	a6,0(sp)
 760:	00114683          	lbu	a3,1(sp)
 764:	00314c03          	lbu	s8,3(sp)
 768:	00214783          	lbu	a5,2(sp)
 76c:	0188181b          	slliw	a6,a6,0x18
 770:	0106969b          	slliw	a3,a3,0x10
 774:	00d86833          	or	a6,a6,a3
 778:	01886833          	or	a6,a6,s8
 77c:	0087979b          	slliw	a5,a5,0x8
 780:	00f86833          	or	a6,a6,a5
 784:	0008081b          	sext.w	a6,a6
 788:	f0cad4e3          	bge	s5,a2,690 <read_srec+0x4d0>
 78c:	ffa5869b          	addiw	a3,a1,-6
 790:	02069693          	slli	a3,a3,0x20
 794:	00110793          	addi	a5,sp,1
 798:	0206d693          	srli	a3,a3,0x20
 79c:	00f686b3          	add	a3,a3,a5
 7a0:	41d805b3          	sub	a1,a6,t4
 7a4:	000e8793          	mv	a5,t4
 7a8:	00f58633          	add	a2,a1,a5
 7ac:	0047c803          	lbu	a6,4(a5)
 7b0:	01f66633          	or	a2,a2,t6
 7b4:	01060023          	sb	a6,0(a2)
 7b8:	00178793          	addi	a5,a5,1
 7bc:	fed796e3          	bne	a5,a3,7a8 <read_srec+0x5e8>
 7c0:	0012829b          	addiw	t0,t0,1
 7c4:	a8dff06f          	j	250 <read_srec+0x90>
 7c8:	00014683          	lbu	a3,0(sp)
 7cc:	00114783          	lbu	a5,1(sp)
 7d0:	00214803          	lbu	a6,2(sp)
 7d4:	0106969b          	slliw	a3,a3,0x10
 7d8:	0087979b          	slliw	a5,a5,0x8
 7dc:	00f6e6b3          	or	a3,a3,a5
 7e0:	0106e6b3          	or	a3,a3,a6
 7e4:	eaca56e3          	bge	s4,a2,690 <read_srec+0x4d0>
 7e8:	ffb5859b          	addiw	a1,a1,-5
 7ec:	02059813          	slli	a6,a1,0x20
 7f0:	00110793          	addi	a5,sp,1
 7f4:	02085813          	srli	a6,a6,0x20
 7f8:	00f80833          	add	a6,a6,a5
 7fc:	41d685b3          	sub	a1,a3,t4
 800:	000e8793          	mv	a5,t4
 804:	00f586b3          	add	a3,a1,a5
 808:	0037c603          	lbu	a2,3(a5)
 80c:	01f6e6b3          	or	a3,a3,t6
 810:	00c68023          	sb	a2,0(a3)
 814:	00178793          	addi	a5,a5,1
 818:	ff0796e3          	bne	a5,a6,804 <read_srec+0x644>
 81c:	0012829b          	addiw	t0,t0,1
 820:	a31ff06f          	j	250 <read_srec+0x90>
 824:	00015783          	lhu	a5,0(sp)
 828:	0087d81b          	srliw	a6,a5,0x8
 82c:	0087969b          	slliw	a3,a5,0x8
 830:	0106e6b3          	or	a3,a3,a6
 834:	03069693          	slli	a3,a3,0x30
 838:	0306d693          	srli	a3,a3,0x30
 83c:	e4c9dae3          	bge	s3,a2,690 <read_srec+0x4d0>
 840:	ffc5859b          	addiw	a1,a1,-4
 844:	02059813          	slli	a6,a1,0x20
 848:	00110793          	addi	a5,sp,1
 84c:	02085813          	srli	a6,a6,0x20
 850:	00f80833          	add	a6,a6,a5
 854:	41d685b3          	sub	a1,a3,t4
 858:	000e8793          	mv	a5,t4
 85c:	00f586b3          	add	a3,a1,a5
 860:	0027c603          	lbu	a2,2(a5)
 864:	01f6e6b3          	or	a3,a3,t6
 868:	00c68023          	sb	a2,0(a3)
 86c:	00178793          	addi	a5,a5,1
 870:	ff0796e3          	bne	a5,a6,85c <read_srec+0x69c>
 874:	0012829b          	addiw	t0,t0,1
 878:	9d9ff06f          	j	250 <read_srec+0x90>
 87c:	00058793          	mv	a5,a1
 880:	dc5ff06f          	j	644 <read_srec+0x484>
 884:	00058793          	mv	a5,a1
 888:	00000693          	li	a3,0
 88c:	c59ff06f          	j	4e4 <read_srec+0x324>
 890:	fff00513          	li	a0,-1
 894:	e55ff06f          	j	6e8 <read_srec+0x528>
 898:	00200513          	li	a0,2
 89c:	e4dff06f          	j	6e8 <read_srec+0x528>

Disassembly of section .rodata:

00000000000008a0 <__DATA_BEGIN__-0x660>:
 8a0:	0824                	addi	s1,sp,24
 8a2:	0000                	unimp
 8a4:	07c8                	addi	a0,sp,964
 8a6:	0000                	unimp
 8a8:	075c                	addi	a5,sp,900
 8aa:	0000                	unimp
 8ac:	0690                	addi	a2,sp,832
 8ae:	0000                	unimp
 8b0:	067c                	addi	a5,sp,780
 8b2:	0000                	unimp
 8b4:	0690                	addi	a2,sp,832
 8b6:	0000                	unimp
 8b8:	0740                	addi	s0,sp,900
 8ba:	0000                	unimp
 8bc:	0720                	addi	s0,sp,904
 8be:	0000                	unimp
 8c0:	06bc                	addi	a5,sp,840
 8c2:	0000                	unimp
 8c4:	0000                	unimp
 8c6:	0000                	unimp
 8c8:	6854                	ld	a3,144(s0)
 8ca:	7369                	lui	t1,0xffffa
 8cc:	6920                	ld	s0,80(a0)
 8ce:	49522073          	csrs	0x495,tp
 8d2:	562d4353          	0x562d4353
 8d6:	0021                	c.nop	8

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

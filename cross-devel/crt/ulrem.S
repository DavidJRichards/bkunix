/*
 * Program: ulrem.s
 * Copyright 1993, GTE Government Systems
 * Author:  Steven M. Schultz
 *
 *  Version	Date		Modification
 *	0.0	02Feb91		1. Initial inspiration struck.
 *	1.0	05Jun93		2. Released into the Public Domain.
 *
 * This file is part of BKUNIX project, which is distributed
 * under the terms of the GNU General Public License (GPL).
 * See the accompanying file "COPYING" for more details.
 */

/*
 * u_long ulrem(lhs, rhs)
 *	u_long	lhs, rhs;
 *
 * 32-bit "%" routine.  Calls to ulrem are generated automatically by the C
 * compiler.
 */
	.globl ulrem
ulrem:
	mov	r2,-(sp)	/ faster than csv/cret ...
	mov	r3,-(sp)
	mov	r4,-(sp)
	mov	8(sp),r0	/ r0 = hi(lhs)
	mov	10(sp),r1	/ r1 = lo(lhs)
	mov	12(sp),r2	/ r2 = hi(rhs)
	mov	14(sp),r3	/ r3 = lo(rhs)
	bne	3f
	tst	r2
	beq	9f		/ check for divide by 0
3:
	clr	r4		/ init scale of lhs
2:
	asl	r1		/ left shift
	rol	r0
	blos	1f		/ check for zero at same time
	inc	r4
	br	2b
1:
	mov	r4,-(sp)	/ save scale of lhs
	clr	r4
2:
	asl	r3
	rol	r2
	bcs	1f
	inc	r4		/ bump rhs scale
	br	2b
1:
	clr	r0
	mov	$1,r1
	sub	(sp)+,r4	/ difference in scale (rhs - lhs)
	beq	5f
	bhis	4f
	mov	8(sp),r0	/ lhs < rhs
	mov	10(sp),r1	/ return it
	br	9f
4:
	mov	r4,-(sp)
3:
	asl	r1		/ left shift
	rol	r0		/ initial quotient adder
	sob	r4,3b
	mov	(sp)+,r4
5:
	mov	r1,-(sp)	/ quoadder lo
	mov	r0,-(sp)	/ quoadder hi
	mov	12(sp),r0	/ r0 = hi(lhs)
	mov	14(sp),r1	/ r1 = lo(lhs)
	mov	16(sp),r2	/ r2 = hi(rhs)
	mov	18(sp),r3	/ r3 = lo(rhs)
	tst	r4
	beq	4f
3:
	asl	r3		/ left shift
	rol	r2		/ scale rhs up for repetitive subtraction
	sob	r4,3b
	clr	r4		/ quo lo
4:
	clr	-(sp)		/ quo hi
docmp1:
	cmp	r2,r0
	bhi	noadd1
	blo	dosub1
	cmp	r3,r1
	bhi	noadd1
dosub1:
	sub	r3,r1
	sbc	r0
	sub	r2,r0
	add	4(sp),r4	/ quo lo += quoadder lo
	adc	(sp)		/ quo hi
	add	2(sp),(sp)	/ quo hi += quoadder hi
	br	docmp1
noadd1:
	clc			/ right shift rhs
	ror	r2
	ror	r3
	clc			/ right shift quotient adder
	ror	2(sp)
	ror	4(sp)
	bne	docmp1		/ quo adder not 0 means more to do
	tst	2(sp)
	bne	docmp1
	add	$6,sp		/ remove quo adder and quo high
9:
	mov	(sp)+,r4	/ r0,r1 have remainder
	mov	(sp)+,r3
	mov	(sp)+,r2
	rts	pc

/*
 * u_long ualrem(lhs, rhs)
 *	u_long	*lhs, rhs;
 *
 * 32-bit "/=" routine.  Calls to ualrem are generated automatically by the C
 * compiler.
 */

	.globl	ualrem
ualrem:
	mov	r2,-(sp)	/ need a register to point at the lhs
	mov	8(sp),-(sp)	/ The rem algorithm is long
	mov	8(sp),-(sp)	/   enough that it just doesn't make sense
	mov	8(sp),r2	/   to bother repeating it.  We just translate
	mov	2(r2),-(sp)	/   the call for ulrem and let it do the work
	mov	(r2),-(sp)	/   and return its results (also stuffing it
	jsr	pc,ulrem	/   into *lhs)
	add	$8,sp		/ clean up stack
	mov	r0,(r2)+	/ store high word,
	mov	r1,(r2)		/   and low
	mov	(sp)+,r2	/ restore r2
	rts	pc		/   and return

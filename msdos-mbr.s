.code16

sector_start:

	jmp	start
	nop

.ascii	"MSDOS5.0"
.hword	0x0200
.byte	0x01
.hword	0x0001
.byte	0x02
.hword	0x00e0
.hword	0x0040
.byte	0xf0
.hword	0x0009
.hword	0x0012
.hword	0x0002
.long	0x00000000
.long	0x00000000
.byte	0x00
.byte	0x00
.byte	0x29
.long	0x5a541826
.ascii	"NO NAME    "
.ascii	"FAT12   "

.org sector_start + 0x003e

start:
	cli				# interrupts off
	xor	%ax, %ax		# AX = 0x0000
	mov	%ax, %ss		# AX = 0x0000
	mov	$0x7c00, %sp		# SP = 0x7c00
	push	%ss
	pop	%es			# ES = 0x0000

	mov	$0x0078, %bx		# BX = 0x0078
	lds	%ss:(%bx), %si		# DS:SI = (0000:0078)
	push	%ds
	push	%si
	push	%ss
	push	%bx

	mov	$start, %di
	mov	$11, %cx
	cld
	repz
	movsb
	push	%es
	pop	%ds

	movb	$0x0f, -2(%di)
	mov	(0x7c18), %cx
	mov	%cl, -7(%di)

	mov	%ax, 2(%bx)
	movw	$start, (%bx)

	sti
	int	$0x13
	jb nsd

	xor	%ax, %ax
	cmp	%ax, (0x7c13)
	jz	small_disk
	mov	(0x7c13), %cx
	mov	%cx, (0x7c20)

small_disk:
	mov	(0x7c10), %al
	mulw	(0x7c16)
	add	(0x7c1c), %ax
	adc	(0x7c1e), %dx
	add	(0x7c0e), %ax
	adc	$0, %dx
	mov	%ax, (0x7c50)
	mov	%dx, (0x7c52)
	mov	%ax, (0x7c49)
	mov	%dx, (0x7c4b)

	mov	$0x0020, %ax
	mulw	(0x7c11)
	mov	(0x7c0b), %bx
	add	%ax, %bx
	dec	%ax
	div	%bx
	add	%ax, (0x7c49)
	adcw	$0, (0x7c4b)

	mov	$0x0500, %bx
	mov	(0x7c52), %dx
	mov	(0x7c50), %ax
	call	end
	jb	nsd
	mov	$1, %al
	call	end
	jb	nsd
	mov	%bx, %di
	mov	$0x000b, %cx
	mov	$0x7de6, %si
	repz
	cmpsb
	jnz	nsd
	lea	32(%bx), %di
	mov	$11, %cx
	repz
	cmpsb
	jz end

nsd:
	mov	$0x7d9e, %si
	call	end
	xor	%ax, %ax

end:

.org sector_start + 0x01fe
.byte 0x55
.byte 0xaa


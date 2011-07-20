
.code16

sector_start:

	jmp	start				# eb 52
	nop					# 90

# 0x7c0e  0x10 (byte)
# 0x7c10  -> %eax (long)
# 0x7c14  0 = extended disk access not supported; 1 = supported (byte)
# 0x7c20  (max_cyl_num + 1) * (max_head_num + 1) * max_sec_num (long)
# 0x7c24  drive for int 0x13 (byte)

.ascii	"NTFS    "
.word	0x0200		# bytes per sector
.byte	0x08		# sectors per cluster
.word	0x0000		# number of sectors to copy, populated by boot sector
.byte	0x00		# reserved
.word	0x0000		# reserved
.word	0x0000		# reserved
.byte	0xf8		# media descriptor
.word	0x0000		# reserved
.word	0x003f		# sectors per track
.word	0x00ff		# number of heads
.long	0x0000003f	# number of hidden sectors
.long	0x00000000	# total number of sectors, populated by boot sector
.byte	0x80,0,0x80,0	# first byte is the drive for BIOS calls
.long	0,0		# total sectors in volume
.long	0,0		# start cluster of $MFT file in partition
.long	0,0		# start cluster of $MFTMirror file in partition
.long	0x000000f6	# clusters per file record segment (FRS)
.long	0x00000001	# clusters per index blocka
.long	0,0		# serial number
.long	0		# checksum

start:
	cli				# disable interrupts
	xor	%ax, %ax
	mov	%ax, %ss		# setup stack segment (%ss = 0)
	mov	$0x7c00, %sp		# setup stack pointer
	sti				# enable interrupts

	mov	$0x7c0, %ax
	mov	%ax, %ds		# %ds = 0x7c00
	call	disk_params_007b	# get disk parameters
	mov	$0x0d00, %ax
	mov	%ax, %es		# %es = 0x0d00
	xor	%bx, %bx		# %bx = 0
	movb	$0x10, 0x000e
	call	_0x00c7			#
	push	$0x0d00
	push	$0x026a
	lret				# jump to 0d00:026a


# disk_params
#
# Input:
#   (0x24) - disk
#
# Output:
#   (0x20) - (max_cylinder_num + 1) * (max_head_num + 1) * max_sector_num
#
disk_params_007b:
	mov	0x24, %dl		# get disk
	mov	$0x08, %ah		# calling get drive parameters
	int	$0x13				# cd 13
	jnc	disk_params_008a		# 73 05
	mov	$0xffff, %cx			# b9 ff ff
	mov	%cl, %dh			# 8a f1
disk_params_008a:
	movzbl	%dh, %eax			# 66 0f b6 c6
	inc	%ax				# 40
	movzbl	%cl, %edx			# 66 0f b6 d1
	and	$0x3f, %dl			# 80 e2 3f
	mul	%dx				# f7 e2
	xchg	%cl, %ch			# 86 cd
	shr	$0x6, %ch			# c0 ed 06
	inc	%cx				# 41
	movzwl	%cx, %ecx			# 66 0f b7 c9
	mul	%ecx				# 66 f7 e1
	mov	%eax, 0x20			# 66 a3 20 00
	ret					# c3


# ext_disk_check
#
# Input:
#   (0x24) - disk
#
# Output:
#   (0x14) - 1 = extended disk access supported; 0 = not supported
#
ext_disk_check_00aa:
	mov	$0x41, %ah			# b4 41
	mov	$0x55aa, %bx			# bb aa 55
	mov	36, %dl				# 8a 16 24 00
	int	$0x13				# cd 13
	jc	ext_disk_check_00c6		# 72 0f
	cmp	$0xaa55, %bx			# 81 fb 55 aa
	jne	ext_disk_check_00c6		# 75 09
	test	$0x1, %cl			# f6 c1 01
	je	ext_disk_check_00c6		# 74 04
	incb	0x14				# fe 06 14 00
ext_disk_check_00c6:
	ret					# c3

_0x00c7:
	pushal 				# push everything to the stack
	push	%ds			# push %ds to the stack
	push	%es			# push %es to the stack
_0x00cb:
	mov	0x0010, %eax		#
	add	0x001c, %eax		# %eax = (0x7c10) + 28
	cmp	0x0020, %eax
#	jb	_0x0117			# is %eax less than 32?
.byte	0x0f, 0x82, 0x3a, 0x00
	push	%ds			# push %ds to the stack
	pushl	$0x00000000		# push 0x00000000 to the stack
	push	%eax			# push %eax to the stack
	push	%es			# push %es to the stack
	push	%bx			# push %bx to the stack
	pushl	$0x00010010		# push 0x00010010 to the stack
	cmpb	$0, 0x0014
#	jne	_0x0100			# extenstions available, skip check
.byte	0x0f, 0x85, 0x0c, 0x00
	call	ext_disk_check_00aa	# check for extensions
	cmpb	$0, 0x0014
#	je	disk_err_halt_0161	# halt if not available
.byte	0x0f, 0x84, 0x61, 0x00
_0x0100:
	mov	$0x42, %ah		# b4 42
	mov	0x0024, %dl		# 8a 16 24 00
	push	%ss			# 16
	pop	%ds			# 1f
	mov	%sp, %si		# 8b f4
	int	$0x13			# cd 13
	pop	%eax			# 66 58
	pop	%bx			# 5b
	pop	%es			# 07
	pop	%eax			# 66 58
	pop	%eax			# 66 58
	pop	%ds			# 1f
	jmp	_0x0144			# eb 2d
_0x0117:
	xor	%edx, %edx		# %edx = 0
	movzwl	0x0018, %ecx		# %ecx = (0x0018)
	div	%ecx			# %edx:%eax = %eax * %ecx + %edx
	inc	%dl			# %dl += 1
	mov	%dl, %cl		# %cl = %dl
	mov	%eax, %edx		# 66 8b d0
	shr	$16, %edx		# 66 c1 ea 10
	divw	0x001a			# f7 36 1a 00
	xchg	%dl, %dh		# 86 d6
	mov	0x0024, %dl		# 8a 16 24 00
	mov	%al, %ch		# 8a e8
	shl	$6, %ah			# c0 e4 06
	or	%ah, %cl		# 0a cc
	mov	$0x0201, %ax		# read 1 sector into memory
	int	$0x13			# call the routine (%ah = 0x02)
_0x0144:
#	jc	disk_err_halt_0161	# 0f 82 19 00
.byte	0x0f, 0x82, 0x19, 0x00
	mov	%es, %ax		# 8c c0
	add	$0x20, %ax		# 05 20 00
	mov	%ax, %es		# 8e c0
	incl	0x0010			# 66 ff 06 10 00
	decw	0x000e			# ff 0e 0e 00
#	jne	0xcb			# 0f 85 6f ff
.byte	0x0f, 0x85, 0x6f, 0xff
	pop	%es			# 07
	pop	%ds			# 1f
	popal				# 66 61
	ret				# c3


# disk_err_halt
#
# Prints the following error message and halts.
#
#     A disk read error occurred
#     Press Ctrl+Alt+Del to restart
#
disk_err_halt_0161:
	mov	0x1f8, %al		# offset from 0x0100 to string
	call	print_0170		# print "A disk read error ..."
	mov	0x1fb, %al		# offset from 0x0100 to string
	call	print_0170		# print "Press Ctrl+Alt+Del ..."
	sti
disk_err_halt_016e:
	jmp	disk_err_halt_016e


# print
#
# Prints a NUL-terminated string to the console.
#
# Input:
#   %al - low-order bits for an address of the form 0x01xx pointing to
#       a NUL-terminated string
#   %ds - segment for string pointer
#
print_0170:
	mov	$0x1, %ah		# set %ax to point to string
	mov	%ax, %si		# set %si to point to string
print_0174:
	lods	(%si), %al		# load character into %al
	cmp	$0, %al			# check if end of string reached
	je	print_0182
	mov	$0x0e, %ah		# calling teletype output
	mov	$0x0007, %bx		# %bh = page #; %bl = fg color
	int	$0x10			# call the routine (%ah = 0x0e)
	jmp	print_0174
print_0182:
	ret


.asciz	"\r\nA disk read error occurred"
.asciz	"\r\nNTLDR is missing"
.asciz	"\r\nNTLDR is compressed"
.asciz	"\r\nPress Ctrl+Alt+Del to restart\r\n"

.org	sector_start + 0x01f8
.byte	0x83	# 0x183 is location of YA disk read ..."
.byte	0xa0	# 0x1a0 is location of "NTLDR is mis..."
.byte	0xb3    # 0x1b3 is location of "NTLDR is com..."
.byte	0xc9    # 0x1c9 is location of "Press Ctrl+A..."

.org	sector_start + 0x01fe
.byte	0x55, 0xaa


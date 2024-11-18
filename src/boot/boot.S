/*****************************************************************************
 * Copyright  2024  Emisilve86                                               *
 *                                                                           *
 * This file is part of HelloWorldOS.                                        *
 *                                                                           *
 * HelloWorldOS is free software: you can redistribute it and/or modify      *
 * it under the terms of the GNU General Public License as published by      *
 * the Free Software Foundation, either version 3 of the License, or         *
 * (at your option) any later version.                                       *
 *                                                                           *
 * HelloWorldOS is distributed in the hope that it will be useful,           *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of            *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             *
 * GNU General Public License for more details.                              *
 *                                                                           *
 * You should have received a copy of the GNU General Public License         *
 * along with Nome-Programma.  If not, see <http://www.gnu.org/licenses/>.   *
 *****************************************************************************/


.text

####################################
#      REAL-MODE 16-BIT CODE       #
#      x86 AND i386 COMPLIANT      #
#                                  #
# |                     |          #
# |       *free*        |          #
# |---------------------| 0x100000 #
# |        BIOS         |          #
# |---------------------| 0xc0000  #
# |    Video Memory     |          #
# |---------------------| 0xa0000  #
# |  Extended BIOS Data |          #
# |---------------------| 0x9fc00  #
# |       *free*        |          #
# |---------------------| 0x7e00   #
# |     Bootloader      |          #
# |---------------------| 0x7c00   #
# |       *free*        |          #
# |---------------------| 0x500    #
# |      BIOS Data      |          #
# |---------------------| 0x400    #
# |    IVT Real-Mode    |          #
# |_____________________| 0x0      #
#                                  #
####################################

.code16

.macro rm_stack_wind
	pushw	%bp
	movw	%sp,		%bp
	pusha
.endm

.macro rm_stack_unwind
	popa
	popw	%bp
.endm

.equ	RM_STACK,	0x8000

/* BIOS-based bootloaders are loaded
   at address 0x7c00 and the segment
   registers are still zero-ed */

.globl	_start
.type _start, @function
_start:
	movw	$RM_STACK,	%bp
	movw	%bp,		%sp

	call	set_v_mode

	movw	%dx,		%di
	call	disk_read

	call	leave_rm

	jmp		.

/* Int 10,0 will trigger the BIOS service
   routine used to set the video mode */

.type set_v_mode, @function
set_v_mode:
	rm_stack_wind

	movb	$0x03,		%al		/* 80x25 16 color text */
	movb	$0x00,		%ah		/* set video mode */
	int		$0x10

	rm_stack_unwind
	ret

.equ	SECT_NUM,	0x1f
.equ	KERN_OFF,	0x1000

/* Int 13,2 will trigger the BIOS service
   routine used to read from the specified
   unit drive */

.type disk_read, @function
disk_read:
	rm_stack_wind

	movw	%di,		%dx		/* drive index (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1) */

	movb	$0x02,		%ah		/* read from the drive */
	movb	$SECT_NUM,	%al		/* number of sectors to read */
	movb	$0x00,		%ch		/* track/cylinder number */
	movb	$0x02,		%cl		/* initial sector number */
	movb	$0x00,		%dh		/* head number */
	movw	$KERN_OFF,	%bx		/* destination memory address */
	int		$0x13

	cmpb	$0x00,		%ah		/* returned status 0 means no error */
	jne		1f

	cmpb	$SECT_NUM,	%al		/* number of sectors actually read */
	je		2f
1:
	leaw	disk_error,	%di
	call	bios_p_string

	jmp		.
2:
	rm_stack_unwind
	ret

.include	"gdt.S"

/* Instruction lgdt loads the GDT description to
   the apposite register while the 1st bit of the
   control register CR0 enables the Protected-Mode */

.type leave_rm, @function
leave_rm:
	rm_stack_wind

	cli

	lgdt	gdt_descriptor

	movl	%cr0,		%eax
	orb		$0x01,		%al
	movl	%eax,		%cr0

	/* Long jump to load the index of CODE segment
	   within the CS register */

	ljmp	$SEG_CODE,	$enter_pm

	jmp		.

	rm_stack_unwind
	ret

/* Iterate over ASCII strings up to the first
   encountered NUL byte */

.type bios_p_string, @function
bios_p_string:
	rm_stack_wind
1:
	movb	(%di),		%al
	cmpb	$0x00,		%al
	je		2f

	xorw	%ax,		%di
	xorw	%di,		%ax
	xorw	%ax,		%di
	call	bios_p_byte

	movw	%ax,		%di
	addw	$0x0001,	%di
	jmp		1b
2:
	movw	$0x000d,	%di
	call	bios_p_byte

	movw	$0x000a,	%di
	call	bios_p_byte

	rm_stack_unwind
	ret

/* Int 10,E will trigger the BIOS service
   routine used to write text in teletype
   mode to video */

.type bios_p_byte, @function
bios_p_byte:
	rm_stack_wind

	movw	%di,		%ax		/* ASCII character to write */
	movb	$0x0e,		%ah		/* write text in teletype mode */
	int		$0x10

	rm_stack_unwind
	ret

####################################
#    PROTECTED-MODE 32-BIT CODE    #
#      x86 AND i386 COMPLIANT      #
#                                  #
# |                     |          #
# |       *free*        |          #
# |---------------------| 0xc0000  #
# |    Video Memory     |          #
# |---------------------| 0xa0000  #
# |       *free*        |          #
# |---------------------| 0x7e00   #
# |     Bootloader      |          #
# |---------------------| 0x7c00   #
# |       *free*        |          #
# |---------------------| 0x--00   #
# |       Kernel        |          #
# |---------------------| 0x1000   #
# |       *free*        |          #
# |_____________________| 0x0      #
#                                  #
####################################

.code32		/* Start of 32-bit code */

.macro pm_stack_wind		/* create the stack frame when entering a function */
	pushl	%ebp
	movl	%esp,		%ebp
	pushal
.endm

.macro pm_stack_unwind		/* destroy the stack frame when leaving a function */
	popal
	popl	%ebp
.endm

.equ	PM_STACK,	0x90000

/* Once entered the Protected-Mode all segment
   registers need to be initialized with the
   index value of the DATA segment */

.type enter_pm, @function
enter_pm:
	movw	$SEG_DATA,	%ax
	movw	%ax,		%ds
	movw	%ax,		%ss
	movw	%ax,		%es
	movw	%ax,		%fs
	movw	%ax,		%gs

	movl	$PM_STACK,	%ebp
	movl	%ebp,		%esp

	/* Call the first instruction belonging to the
	   Kernel image loaded at 0x1000 */

	call	KERN_OFF

	leal	kernel_error,	%edi
	call	vga_p_string

	jmp		.

.equ	VGA_MEM,	0xb8000
.equ	WB_CODE,	0x0f

/* Once Real-Mode is left no BIOS service routine
   is actually available hence sending texts to
   video can be achieved only by writing into the
   memory mapped for VGA cards */

.type vga_p_string, @function
vga_p_string:
	pm_stack_wind

	movl	$VGA_MEM,	%esi
	movb	$WB_CODE,	%ah
1:
	movb	(%edi),		%al
	cmpb	$0x00,		%al
	je		2f

	movw	%ax,		(%esi)

	addl	$0x01,		%edi
	addl	$0x02,		%esi
	jmp		1b
2:
	pm_stack_unwind
	ret

kernel_error:
	.asciz	"Kernel Load Error"

disk_error:
	.asciz	"Disk Read Error"

	. = _start + 510
	.byte	0x55
	.byte	0xaa

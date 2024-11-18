SECTIONS
{
	. = 0x1000;
	.text : { *(.text) }

	. = (. + 0x04) & ~0x04;
	.data : { *(.rodata) }
	.data : { *(.data) }
	.bss : { *(.bss) }

	/DISCARD/ :
	{
		*(.note.gnu.property)
		*(.note.GNU-stack)
		*(.gnu_debuglink)
		*(.gnu.lto_*)
		*(.eh_frame)
		*(.comment)
	}
}
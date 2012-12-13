/*OUTPUT_FORMAT("binary")*/
SECTIONS 
{

    . = 0x100000; 
    .text :
    {
		*(.text)
		*(.data)
		*(.rodata*) /* <---- ELF Cross Compiler or ELF *NIX (eg. Linux) */
		*(.rdata*)  /* <---- COFF/PE MinGW or Cygwin on Windows */
		*(.bss)
	}
	.eh_frame :
	{
		*(.eh_frame)
		*(.comment)
	}
}


/*

	. = 0x10000;
    .text : 
    {
        *(.text)
    }
    .data :
    {
        *(.data) *(.rodata)
    }
    .bss :
    {
        *(.bss)
    }
    
    .eh_frame :
    {
		*(.eh_frame)
		*(.comment)
    }
}
*/
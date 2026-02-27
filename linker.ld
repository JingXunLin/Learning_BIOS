ENTRY(_start)

MEMORY
{
	ROM (rx) : ORIGIN = 0x00000000, LENGTH = 32K
  	SRAM (rw) : ORIGIN = 0x10000000, LENGTH = 8K
	RAM (rwx) : ORIGIN = 0x40000000, LENGTH = 512M
}

SECTIONS
{
	_srom = 0x0;
	
	.start_code : ALIGN(4)
    {
        *(.text.init) 
    } > ROM

	.text : ALIGN(4)
	{
		_stext_vma = .;
		*(.text)
		_etext_vma = .;
	} > RAM AT > ROM   /* 執行在 RAM，載入在 ROM，Linker 會自動接在 start_code 後面 */
	_stext_lma = LOADADDR(.text);
	_etext_lma = _stext_lma + SIZEOF(.text);

	.data : ALIGN(4)
	{
		. = ALIGN(4);
		_sdata_vma = .;
		*(.data)
		*(.rodata)
		*(.sdata)
		_edata_vma = .;
	} > RAM AT > ROM
	_sdata_lma = LOADADDR(.data);
	_edata_lma = _sdata_lma + SIZEOF(.data);

	.bss : ALIGN(4)
	{
		_sbss_vma = .;
		*(.bss)
		_ebss_vma = .;
	} >RAM
	_sbss_lma = LOADADDR(.bss);
	_ebss_lma = _sbss_lma + SIZEOF(.bss);
}
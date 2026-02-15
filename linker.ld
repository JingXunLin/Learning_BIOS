ENTRY(_start)

SECTIONS
{
  . = 0x00000000;
  .text : { *(.text) }
  .data : { *(.data) }
  . = 0x40000000;
  .bss : { *(.bss) }
}
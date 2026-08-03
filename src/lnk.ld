OUTPUT_FORMAT(pei-x86-64)
OUTPUT_ARCH(i386:x86-64)
ENTRY(_e)

SECTIONS
{
    .text :
    {
        *(.text*)
    }

    .data :
    {
        *(.data*)
    }

    .rodata :
    {
        *(.rodata*)
    }

    .bss :
    {
        *(COMMON)
        *(.bss*)
    }
}

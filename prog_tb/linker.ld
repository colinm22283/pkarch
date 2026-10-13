ENTRY(entry)

MEMORY {
    rom (rx)  : ORIGIN = 0x00000000, LENGTH = 16384
    ram (rwx) : ORIGIN = 0x01000000, LENGTH = 0x20000
}

SECTIONS {
    . = 0x0;

    .rom : {
        *(.startup*);
        *(.text*);
        *(.data*);
        *(.rodata*)
    } > rom

    .ram : {
        *(.bss*);
        *(.sbss*);
    } > ram

    /DISCARD/ : { *(*) }
}

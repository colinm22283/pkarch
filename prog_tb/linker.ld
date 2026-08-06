ENTRY(entry)

MEMORY {
    ram (rwx) : ORIGIN = 0, LENGTH = 16384
}

SECTIONS {
    . = 0x0;

    .ram : {
        *(.startup*);
        *(.text*);
        *(.data*);
        *(.bss*);
        *(.rodata*)
    } > ram

    /DISCARD/ : { *(*) }
}

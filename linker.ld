/* linker.ld */
/* Script pour lier un noyau i386 simple */

ENTRY(_start) /* Définit le point d'entrée _start (défini dans boot.asm) */

SECTIONS
{
    /* Commence à l'adresse 1 Mo (0x100000). C'est une convention courante. */
    . = 1M;

    /* Section .text : Code exécutable */
    .text BLOCK(4K) : ALIGN(4K)
    {
        *(.multiboot)   /* Place l'en-tête Multiboot en premier ! */
        *(.text)        /* Ensuite, le reste du code */
    }

    /* Section .rodata : Données en lecture seule */
    .rodata BLOCK(4K) : ALIGN(4K)
    {
        *(.rodata)
    }

    /* Section .data : Données initialisées */
    .data BLOCK(4K) : ALIGN(4K)
    {
        *(.data)
    }

    /* Section .bss : Données non initialisées */
    /* Mettre _end juste avant .bss pour marquer la fin des données chargées */
    _end = .; PROVIDE(end = .); /* Symbole pratique pour connaître la fin du noyau */
    .bss BLOCK(4K) : ALIGN(4K)
    {
        *(COMMON)
        *(.bss)
    }

    /* Section optionnelle pour ignorer les informations DWARF/debug */
    /DISCARD/ :
    {
        *(.eh_frame)
        *(.comment)
    }
}
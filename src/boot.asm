; src/boot.asm

; On cible l'architecture i386 (32 bits)
BITS 32

; --- Section Multiboot Header ---
; GRUB recherche cette structure pour savoir comment charger le noyau.
section .multiboot
align 4
    ; Magic number (obligatoire)
    MULTIBOOT_HEADER_MAGIC equ 0x1BADB002
    ; Flags (indique que GRUB doit aligner les modules sur une page et fournir une carte mémoire)
    MULTIBOOT_HEADER_FLAGS equ 0x00000003 ; Utilise 0x0 si tu n'as pas besoin de ces infos au début
    ; Checksum (magic + flags + checksum doit être égal à 0)
    MULTIBOOT_HEADER_CHECKSUM equ -(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)

    dd MULTIBOOT_HEADER_MAGIC       ; Champ 'magic'
    dd MULTIBOOT_HEADER_FLAGS       ; Champ 'flags'
    dd MULTIBOOT_HEADER_CHECKSUM    ; Champ 'checksum'
    ; Les champs optionnels de l'en-tête Multiboot v1 peuvent être omis (mis à 0)

; --- Section .text (code exécutable) ---
section .text
global _start                   ; Point d'entrée pour l'éditeur de liens
extern kmain                    ; Référence à la fonction principale en C

_start:
    ; GRUB nous a déjà mis en mode protégé 32 bits.
    ; Il faut configurer une pile (stack) avant d'appeler du code C.
    ; On la place après la fin de notre code/données (bss).
    mov esp, stack_top          ; Initialise le pointeur de pile

    ; Les informations Multiboot sont passées par GRUB dans les registres:
    ; EAX: Contient le magic number 0x2BADB002 (différent de celui du header!)
    ; EBX: Contient l'adresse physique de la structure d'informations Multiboot.
    ; Tu n'en as pas besoin immédiatement, mais garde ça en tête.

    ; Appeler la fonction principale du noyau C
    call kmain

    ; Si kmain retourne (ce qui ne devrait pas arriver dans un noyau),
    ; on arrête le CPU pour éviter des problèmes.
    cli                         ; Désactive les interruptions
.hang:
    hlt                         ; Stoppe le CPU jusqu'à la prochaine interruption (qui n'arrivera pas)
    jmp .hang                   ; Boucle infinie de sécurité

; --- Section .bss (données non initialisées) ---
; Utilisée ici pour réserver de l'espace pour la pile.
section .bss
align 16                        ; Aligne la pile sur 16 octets
stack_bottom:
    resb 16384                  ; Réserve 16KB pour la pile (16 * 1024 octets)
stack_top:                      ; Adresse du sommet de la pile (adresse la plus haute)
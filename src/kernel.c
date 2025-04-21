#include "include/screen.h" 

// La fonction principale du noyau, appelée depuis boot.asm
void kmain(void) {
    // Initialise l'écran (efface et positionne le curseur)
    screen_init();

    // Affiche "42" à l'écran
    print_string("Hello World ! 42, tahia djazair");
    // print_string("2");
    // Ou utiliser print_dec si implémenté :
    // print_dec(42);
    

    // Boucle infinie pour que le noyau ne se termine pas
    for (;;) {
        // Utilise hlt (halt) pour économiser le CPU quand il n'y a rien à faire.
        // Nécessite d'être dans une section asm volatile.
        asm volatile ("hlt");
    }
}
#include "include/screen.h"

// Adresse de base de la mémoire vidéo en mode texte VGA
volatile uint16_t* const VIDEO_MEMORY = (uint16_t*)0xB8000;
// Dimensions de l'écran en mode texte (généralement 80x25)
const size_t SCREEN_WIDTH = 80;
const size_t SCREEN_HEIGHT = 25;

// Position actuelle du curseur
size_t cursor_x = 0;
size_t cursor_y = 0;

// Couleur par défaut (texte blanc sur fond noir)
// Attribut = (Couleur Fond << 4) | Couleur Texte
// Noir=0, Blanc=15

// const uint8_t DEFAULT_COLOR = (0 << 4) | 15;
const uint8_t DEFAULT_COLOR = (0 << 4) | 5;



// Fonction interne pour créer une entrée VGA (caractère + couleur)
static inline uint16_t vga_entry(char c, uint8_t color) {
    return (uint16_t)c | (uint16_t)color << 8;
}

// Initialise l'écran
void screen_init() {
    clear_screen();
}

// Efface l'écran en remplissant avec des espaces
void clear_screen() {
    cursor_x = 0;
    cursor_y = 0;
    for (size_t y = 0; y < SCREEN_HEIGHT; ++y) {
        for (size_t x = 0; x < SCREEN_WIDTH; ++x) {
            const size_t index = y * SCREEN_WIDTH + x;
            VIDEO_MEMORY[index] = vga_entry(' ', DEFAULT_COLOR);
        }
    }
    // Note: On ne met pas à jour le curseur matériel ici,
    // mais pour un simple affichage, ça suffit.
}

// Affiche un caractère à la position (x, y)
static void put_char_at(char c, uint8_t color, size_t x, size_t y) {
    const size_t index = y * SCREEN_WIDTH + x;
    VIDEO_MEMORY[index] = vga_entry(c, color);
}

// Gère le défilement (scrolling) si nécessaire
static void scroll_screen() {
    // Déplace chaque ligne une position vers le haut
    for (size_t y = 0; y < SCREEN_HEIGHT - 1; ++y) {
        for (size_t x = 0; x < SCREEN_WIDTH; ++x) {
            const size_t index_current = y * SCREEN_WIDTH + x;
            const size_t index_next = (y + 1) * SCREEN_WIDTH + x;
            VIDEO_MEMORY[index_current] = VIDEO_MEMORY[index_next];
        }
    }
    // Efface la dernière ligne
    for (size_t x = 0; x < SCREEN_WIDTH; ++x) {
        const size_t index = (SCREEN_HEIGHT - 1) * SCREEN_WIDTH + x;
        VIDEO_MEMORY[index] = vga_entry(' ', DEFAULT_COLOR);
    }
    cursor_y = SCREEN_HEIGHT - 1; // Place le curseur sur la nouvelle dernière ligne
}


// Affiche un caractère à la position actuelle du curseur
void print_char(char c) {
    if (c == '\n') { // Gérer le retour à la ligne
        cursor_x = 0;
        cursor_y++;
    } else if (c >= ' ') { // Caractère imprimable
        put_char_at(c, DEFAULT_COLOR, cursor_x, cursor_y);
        cursor_x++;
    }

    // Si on dépasse la largeur de l'écran
    if (cursor_x >= SCREEN_WIDTH) {
        cursor_x = 0;
        cursor_y++;
    }

    // Si on dépasse la hauteur de l'écran (scrolling nécessaire)
    if (cursor_y >= SCREEN_HEIGHT) {
         scroll_screen(); // Utilise la fonction scroll si nécessaire
         // Ou simplement réinitialise si pas de scroll :
         // clear_screen();
    }

    // Note: Mise à jour du curseur matériel omise pour la simplicité
}


// Affiche une chaîne de caractères
void print_string(const char* str) {
    for (size_t i = 0; str[i] != '\0'; ++i) {
        print_char(str[i]);
    }
}

// Fonction TRES basique pour afficher un entier positif
void print_dec(int n) {
    if (n == 0) {
        print_char('0');
        return;
    }
    if (n < 0) { // Gère les négatifs (basique)
        print_char('-');
        n = -n;
    }
    char buffer[12]; // Suffisant pour un int 32 bits + signe + '\0'
    int i = 10;
    buffer[11] = '\0';
    while (n > 0) {
        buffer[i--] = (n % 10) + '0';
        n /= 10;
    }
     print_string(&buffer[i + 1]);
}
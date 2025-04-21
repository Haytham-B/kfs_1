// include/screen.h
#ifndef SCREEN_H
#define SCREEN_H

#include <stddef.h> // Pour size_t
#include <stdint.h> // Pour uint8_t, uint16_t

// Efface l'écran
void clear_screen();

// Affiche un caractère à la position actuelle du curseur
void print_char(char c);

// Affiche une chaîne de caractères
void print_string(const char* str);

// Affiche un nombre décimal (simple)
void print_dec(int n); // Utile pour afficher "42"

// Initialise l'interface écran (efface, positionne le curseur)
void screen_init();

#endif // SCREEN_H
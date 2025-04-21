# Makefile

# --- Programmes ---
CC = gcc
AS = nasm
LD = ld

# --- Drapeaux de compilation C ---
# -m32: Compiler pour architecture 32 bits (i386)
# -ffreestanding: Indique qu'on n'est pas dans un environnement hébergé (pas de stdlib OS)
# -nostdlib: Ne pas lier avec la bibliothèque standard C
# -fno-builtin: Ne pas utiliser les fonctions C intégrées (comme memcpy) qui pourraient dépendre de l'OS
# -fno-stack-protector: Désactiver la protection de pile (pas de support noyau pour ça encore)
# -Wall -Wextra: Activer beaucoup d'avertissements (recommandé)
# -Isrc/include: Chercher les headers dans src/include
# -O0: Désactiver les optimisations pour faciliter le débogage au début
# -g: Inclure les informations de débogage (utile avec GDB via QEMU)
CFLAGS = -m32 -ffreestanding -nostdlib -fno-builtin -fno-stack-protector -Wall -Wextra -Isrc/include -O0 -g

# --- Drapeaux de l'assembleur ---
# -f elf: Format de sortie ELF (adapté pour Linux et ld)
ASFLAGS = -f elf

# --- Drapeaux de l'éditeur de liens ---
# -m elf_i386: Utiliser l'émulation i386 pour le lien
# -T linker.ld: Utiliser notre script de lien personnalisé
LDFLAGS = -m elf_i386 -T linker.ld

# --- Fichiers source ---
# Trouve tous les fichiers .c dans src/ et ses sous-répertoires
C_SOURCES = $(wildcard src/**/*.c) $(wildcard src/*.c)
# Trouve tous les fichiers .asm dans src/ et ses sous-répertoires
ASM_SOURCES = $(wildcard src/**/*.asm) $(wildcard src/*.asm)

# --- Fichiers objets ---
# Génère les noms des fichiers objets (.o) à partir des sources C et ASM
# Place les objets dans un répertoire build/ pour garder la racine propre
OBJDIR = build
C_OBJECTS = $(patsubst src/%.c, $(OBJDIR)/%.o, $(C_SOURCES))
ASM_OBJECTS = $(patsubst src/%.asm, $(OBJDIR)/%.o, $(ASM_SOURCES))
OBJECTS = $(ASM_OBJECTS) $(C_OBJECTS)

# --- Cible finale ---
KERNEL_BIN = build/kernel.bin # Notre binaire noyau final
ISO_FILE = kfs1.iso          # L'image ISO bootable

# --- Règles ---

# Cible par défaut: construire l'ISO
all: $(ISO_FILE)

# Règle pour créer l'image ISO
$(ISO_FILE): $(KERNEL_BIN) grub/grub.cfg
	@echo "Creating ISO image..."
	@mkdir -p iso/boot/grub
	@cp $(KERNEL_BIN) iso/boot/kernel.bin
	@cp grub/grub.cfg iso/boot/grub/grub.cfg
	@grub-mkrescue -o $(ISO_FILE) iso --xorriso=xorriso # Utilisation de xorriso explicitement
	@echo "ISO image created: $(ISO_FILE)"

# Règle pour lier les objets et créer le binaire noyau
$(KERNEL_BIN): $(OBJECTS) linker.ld
	@echo "Linking kernel..."
	@$(LD) $(LDFLAGS) -o $(KERNEL_BIN) $(OBJECTS)
	@echo "Kernel binary created: $(KERNEL_BIN)"

# Règle pour compiler les fichiers C (.c -> .o)
$(OBJDIR)/%.o: src/%.c
	@mkdir -p $(@D) # Crée le répertoire de destination si besoin
	@echo "Compiling C: $<"
	@$(CC) $(CFLAGS) -c $< -o $@

# Règle pour assembler les fichiers ASM (.asm -> .o)
$(OBJDIR)/%.o: src/%.asm
	@mkdir -p $(@D) # Crée le répertoire de destination si besoin
	@echo "Assembling: $<"
	@$(AS) $(ASFLAGS) $< -o $@

# Règle pour lancer QEMU avec l'ISO
run: $(ISO_FILE)
	@echo "Starting QEMU..."
	# Utilise l'affichage GTK maintenant disponible
	@qemu-system-i386 -cdrom $(ISO_FILE) -m 128M -display gtk

# Règle pour nettoyer les fichiers objets et binaires
clean:
	@echo "Cleaning build files..."
	@rm -rf $(OBJDIR) $(KERNEL_BIN)

# Règle pour nettoyer tout, y compris l'ISO et le répertoire iso/
fclean: clean
	@echo "Cleaning all generated files..."
	@rm -f $(ISO_FILE)
	@rm -rf iso

# Déclare les cibles qui ne correspondent pas à des noms de fichiers
.PHONY: all run clean fclean
# Utiliser une image de base Linux (Debian est un bon choix)
FROM debian:bullseye

# Installer les dépendances nécessaires
# build-essential: Compilateurs C/C++ (gcc, g++) et make
# nasm: Assembleur Netwide (pour le code ASM)
# grub-pc-bin: Outils GRUB pour PC BIOS (contient grub-mkrescue)
# grub-common: Fichiers communs pour GRUB
# xorriso: Requis par grub-mkrescue pour créer des images ISO
# qemu-system-x86: Émulateur QEMU pour i386/x86_64
# mtools: Utilitaires pour manipuler des systèmes de fichiers DOS (parfois utile)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    nasm \
    grub-pc-bin \
    grub-common \
    xorriso \
    qemu-system-x86 \
    mtools \
    libsdl2-2.0-0 \
    libgtk-3-0 \
    qemu-system-gui \
    && rm -rf /var/lib/apt/lists/*

# Définir le répertoire de travail dans le conteneur
WORKDIR /kfs

# Commande par défaut (optionnelle, peut être lancée interactivement)
# CMD ["bash"]
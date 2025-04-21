- Construire l'Image Docker : Ouvre un terminal à la racine de ton projet et exécute :

    docker build -t kfs-builder .

- Lancer un Conteneur Interactif avec les options X11 : Pour travailler sur ton projet, lance un conteneur basé sur cette image. Le -v $(pwd):/kfs est crucial : il monte le répertoire actuel de ton projet (sur ta machine hôte) dans le répertoire /kfs du conteneur. Toutes les modifications faites dans /kfs (dans le conteneur) seront répercutées sur ta machine hôte et vice-versa:

    # xhost +local:docker (si nécessaire)
    docker run -it --rm \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -e DISPLAY=$DISPLAY \
        -v $(pwd):/kfs \
        kfs-builder bash

- Compile tout avec :

    make

- Lance avec QEMU :

    make run

    ou direct:

    qemu-system-i386 -cdrom kfs1.iso


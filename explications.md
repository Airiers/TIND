<center><h1 align="center">TIND : Comment que ça marche ?</h1></center>

# BIOS

Quand on allume un ordinateur, le premier programme lancé est le BIOS (**B**asic **I**nput **O**utput **S**ystem) ou UEFI (**U**nified **E**xtensible **F**irmware **I**nterface) sur les machines modernes, mais concentrons-nous sur le BIOS.

Ce logiciel se trouve sur une puce de la carte mère, tout est déjà codé par son fabriquant. Le BIOS va se charger d'identifier et de configurer le matériel de l'ordinateur.

# boot.asm

Le Bootloader est un programme chargé par le BIOS au démarrage, il doit obligatoirement se trouver dans le Boot Sector, se terminer par une signature binaire spécifique et peser 512o.

## Initialisation

```asm
dw 0xAA55
```

C'est la signature binaire écrite en Hexadécimale.

```asm
times 510-($-$$) dw 0
```

La signature prends 2o, donc il faut remplir les 510 autres. Cette ligne calcule la taille de notre code depuis la position actuelle `($)` jusqu'à la première ligne `($$)` et remplit le reste avec des 0.

On peux vérifier le résultat avec la commande `nasm -f bin -o boot.bin boot.asm`

## Affichage d'un texte

Le moyen le plus rapide d'afficher des caractères sur l'écran, c'est avec le BIOS.

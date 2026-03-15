<center><h1 align="center">TIND : Comment que ça marche ?</h1></center>

# BIOS

Quand on allume un ordinateur, le premier programme lancé est le BIOS (Basic Input Output System) ou UEFI (Unified Extensible Firmware Interface) sur les machines modernes, mais concentrons-nous sur le BIOS.

Ce logiciel se trouve sur une puce de la carte mère, tout est déjà codé par son fabriquant. Le BIOS va se charger d'identifier et de configurer le matériel de l'ordinateur.

Une fois fait, il execute le test POST (Power-on self-test) qui consiste à vérifier que tout fonctionne bien et à afficher les résultats sur l'écran.

Si tout est OK, il va pouvoir donner les commandes à notre OS.

# boot.asm

Le Bootloader est un programme chargé par le BIOS pour assurer la suite des opérations. Il doit obligatoirement se trouver dans le Boot Sector, se terminer par une signature binaire spécifique et peser 512o.

## Initialisation

Ce Bootloader devra être écrit en Assembly, car c'est le langage qui se traduit le plus directement en binaire pour notre machine.

Commençons par la signature, elle sera écrite en Hexadécimale pour prendre moins de place :

```asm
dw 0xAA55
```

Assurons-nous ensuite que le fichier fasse bien 512o, pour cela, on dois écrire cette instruction :

```asm
times 510-($-$$) db 0
```

La signature prends 2o, donc il faut remplir les 510 autres. Cette ligne calcule la taille de notre code depuis la position actuelle `($)` jusqu'à la première ligne `($$)` et remplit le reste avec des 0.

On peux vérifier le résultat avec la commande `nasm -f bin -o boot.bin boot.asm`

## Affichage d'un texte

Le moyen le plus rapide d'afficher des caractères sur l'écran, c'est avec le BIOS.

En effet, le BIOS affiche à l'écran les résultats du test POST, ce qui signifie qu'il possède une fonction pour afficher du texte. Donc on peux lui demander de l'executer pour nous.

Cette demande se fait via une "Interruption"

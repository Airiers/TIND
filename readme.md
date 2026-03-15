<center><h1 align="center">TIND : Comment que ça marche ?</h1><h2 align="center">TIND project : "TINDS is not DOS"</h2></center>

# BIOS

Quand on allume un ordinateur, le premier programme lancé est le BIOS (Basic Input Output System) ou UEFI (Unified Extensible Firmware Interface) sur les machines modernes, mais concentrons-nous sur le BIOS.

Ce logiciel se trouve sur une puce de la carte mère, tout est déjà codé par son fabriquant. Le BIOS va se charger d'identifier et de configurer le matériel de l'ordinateur.

Une fois fait, il exécute le test POST (Power-on self-test) qui consiste à vérifier que tout fonctionne bien et à afficher les résultats sur l'écran.

Si tout est OK, il va chercher un périphérique de démarrage (disque, clé USB, etc.)
et charger le premier secteur de celui-ci en mémoire.

Ce secteur est appelé le Boot Sector et contient le Bootloader.

# boot.asm

Le Bootloader est le programme chargé par le BIOS pour assurer la suite des opérations. Il doit obligatoirement se trouver dans le Boot Sector, peser exactement 512o et se terminer par une signature binaire spécifique.

Le BIOS charge automatiquement ces 512 octets en mémoire à l'adresse 0x7C00,
puis donne l'exécution au CPU à cet endroit.

## Initialisation

Ce Bootloader devra être écrit en Assembly, car c'est le langage qui se traduit le plus directement en binaire pour notre machine.

Commençons par la signature, elle sera écrite en Hexadécimale pour prendre moins de place :

```asm
dw 0xAA55
```

Assurons-nous ensuite que le fichier fasse bien 512 octets, pour cela, on doit écrire cette instruction avant la signature :

```asm
times 510-($-$$) db 0
```

La signature prends 2 octets, donc il faut remplir les 510 autres. Cette ligne calcule la taille de notre code depuis la position actuelle `($)` jusqu'à la première ligne `($$)` et remplit le reste avec des 0.

on peut vérifier le résultat avec la commande `nasm -f bin -o boot.bin boot.asm`

## Affichage d'un texte

Commençons par le commencement : afficher "Hello World".

Le moyen le plus rapide d'afficher des caractères sur l'écran, c'est avec le BIOS.

En effet, le BIOS affiche à l'écran les résultats du test POST, ce qui signifie qu'il possède une fonction pour afficher du texte. Donc on peut lui demander de l'exécuter pour nous.

Cette demande se fait via une "Interruption", qui consiste à demander au CPU de cesser ce qu'il fait, d'exécuter une demande prioritaire, puis de revenir à ce qu'il faisait avant.

La liste de toutes les interruptions est disponible sur [Wikipédia](https://en.wikipedia.org/wiki/BIOS_interrupt_call#Interrupt_table)

L'interruption `0x10` est celle qui permet de demander au CPU d'utiliser le service d'affichage vidéo du BIOS.

Pour utiliser cette interruption, on va transmettre au BIOS des valeurs via les registres du CPU, des emplacements de données. Plus précisément, en stockant la valeur `0E` dans le registre `AH`, on demande à afficher un caractère à l'écran. Et dans le registre `Al` c'est le caractère à afficher, ici "H". `AH` et `AL` étant les parties haute et basse du registre `AX`.

On donne donc nos variables en modifiant les valeurs des registres du CPU :

```asm
mov ah, 0x0E
mov al, 'H'
```

Puis on appelle l'interruption :

```asm
int 0x10
```

Le CPU prends la main, regarde à quoi l'interruption correspond et donne le contrôle au BIOS qui s'occupe ensuite de regarder quelle fonction on souhaite utiliser.

Il prend donc la valeur du registre `AH`, et sait qu'on veut afficher un caractère. Il prend la valeur du registre `AL` pour savoir lequel, et il l'exécute.

Avant que ce soit bon, il faut une dernière chose : une boucle infinie. Un bout de code que le CPU exécutera sans s'arrêter.

Mais pourquoi ? Tout simplement car il ne s'arrête jamais de travailler, il veut exécuter des instruction non-stop. Et si il arrive à la fin des instructions de notre Bootloader, il commencera à exécuter les instructions qui se trouvent juste après en mémoire, sauf que ce sont des valeurs aléatoires n'ayant aucun rapport, il va donc exécuter n'importe quoi et crasher.

Mais si on le bloque dans notre boucle infinie, il ne crashera pas.

```asm
hang:
    jmp hang
```

Voilà le code final :

```asm
mov ah, 0x0E
mov al, 'H'
int 0x10
hang:
    jmp hang
times 510-($-$$) db 0
dw 0xAA55
```

Voilà, on a affiché la lettre "H" à l'écran. C'est bien hein... mais il nous manque 10 lettres... On pourrait juste copier-coller et puis c'est fait, mais faire ça c'est pas très propre

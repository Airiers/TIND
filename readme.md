<center><h1 align="center">TIND : Comment ça marche ?</h1><h3 align="center">TIND project : "TINDS is not DOS"</h3></center>

# Introduction

Bienvenue !

Ceci est une initiation à l'univers des OS et de son fonctionnement, au cours de laquelle nous aborderons toutes les étapes nécessaires à la création d'un OS basique, en lignes de commandes.

> _💡 **Pour rappel :** Un `OS` (Operating System) est un ensemble de programmes qui dirige l'utilisation des ressources d'un ordinateur_

La réalisation d'un système d'exploitation est une tâche complexe, qui nécessite d'être familier aux concepts informatiques tels que :

- La gestion de la mémoire : comprendre comment le CPU utilise les registres, la pile et le tas pour stocker et manipuler les données.

- L’ordonnancement des processus : savoir comment le système distribue le temps CPU entre différents programmes en cours d’exécution.

- La gestion des interruptions : apprendre comment le système réagit aux événements matériels et logiciels de manière efficace.

- Le système de fichiers : organiser et gérer les fichiers stockés sur les périphériques de manière structurée et sécurisée.

- Les pilotes matériels (drivers) : communiquer correctement avec les périphériques comme le clavier, l’écran, et le disque dur.

Le projet TIND (TINDS is not DOS) vise à concevoir un système d’exploitation minimal mais fonctionnel, en partant de zéro, pour mieux comprendre le fonctionnement interne des machines et les interactions entre matériel et logiciel.

Ces différentes notions seront expliquées autant que possible dans ce document. N’hésitez pas à vous documenter par vous-même pour approfondir certains concepts ou mieux les comprendre.

## Outils utilisés

Nous utiliserons ici l'Assembleur Netwide (NASM) pour générer les fichiers binaires depuis l'assembleur, il est disponible au téléchargement gratuitement [sur leur site](https://www.nasm.us/pub/nasm/releasebuilds/). Ainsi que l'émulateur QEMU, lui aussi disponible gratuitement [sur leur site](https://www.qemu.org/download/).

# BIOS

Quand on allume un ordinateur, le premier programme lancé est le BIOS (Basic Input Output System) ou UEFI (Unified Extensible Firmware Interface) sur les machines modernes, mais concentrons-nous sur le BIOS.

Ce logiciel se trouve sur une puce de la carte mère, tout est déjà codé par son fabriquant. Le BIOS va se charger d'identifier et de configurer le matériel de l'ordinateur.

Une fois fait, il exécute le test [POST](<https://fr.wikipedia.org/wiki/Power-on_self-test_(informatique)>) (Power-on self-test) qui consiste à vérifier que tout fonctionne bien et à afficher les résultats sur l'écran.

Si tout est OK, il va chercher un périphérique de démarrage (disque, clé USB, etc.)
et charger le premier secteur de celui-ci en mémoire.

Ce secteur est appelé le Boot Sector et contient le Bootloader.

# boot.asm

Le Bootloader est le programme chargé par le BIOS à l'emplacement mémoire pour assurer la suite des opérations. Il doit obligatoirement se trouver dans le Boot Sector, peser exactement 512o et se terminer par une signature binaire spécifique.

Le BIOS charge automatiquement ces 512 octets en mémoire à l'adresse `0x7C00`,
puis donne l'exécution au CPU à cet endroit.

## Initialisation

Ce Bootloader devra être écrit en Assembly, car c'est le langage qui se traduit le plus directement en binaire pour notre machine.

Commençons par la signature, elle sera écrite en Hexadécimale pour prendre moins de place :

```asm
dw 0xAA55
```

> _💡 **Pour rappel :** `dw` (define word) définit une expression de deux octets_

Assurons-nous ensuite que le fichier fasse bien 512 octets, pour cela, on doit écrire cette instruction avant la signature :

```asm
times 510-($-$$) db 0
```

La signature prends 2 octets, donc il faut remplir les 510 autres. Cette ligne calcule la taille de notre code depuis la position actuelle `($)` jusqu'à la première ligne `($$)` et remplit le reste avec des 0.

on peut vérifier le résultat avec la commande `nasm -f bin -o boot.bin boot.asm`

## Affichage de caractères

Commençons par le commencement : afficher "Hello World".

Le moyen le plus rapide d'afficher des caractères sur l'écran, c'est avec le BIOS.

En effet, le BIOS affiche à l'écran les résultats du test POST, ce qui signifie qu'il possède une fonction pour afficher du texte. Donc on peut lui demander de l'exécuter pour nous.

Cette demande se fait via une "Interruption", qui consiste à demander au CPU de cesser ce qu'il fait, d'exécuter une demande prioritaire, puis de revenir à ce qu'il faisait avant.

La liste de toutes les interruptions est disponible sur [Wikipédia](https://en.wikipedia.org/wiki/BIOS_interrupt_call#Interrupt_table)

L'interruption `0x10` est celle qui permet de demander au CPU d'utiliser le service d'affichage vidéo du BIOS.

Pour utiliser cette interruption, on va transmettre au BIOS des valeurs via les registres du CPU, des emplacements de données. Plus précisément, en stockant la valeur `0E` dans le registre `ah`, on demande à afficher un caractère à l'écran. Et dans le registre `al` c'est le caractère à afficher, ici "H". `ah` et `al` étant les parties haute et basse du registre `AX`.

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

Il prend donc la valeur du registre `ah`, et sait qu'on veut afficher un caractère. Il prend la valeur du registre `al` pour savoir lequel, et il l'exécute.

Avant que ce soit bon, il faut une dernière chose : une boucle infinie. Un bout de code que le CPU exécutera sans s'arrêter.

Mais pourquoi ? Tout simplement car il ne s'arrête jamais de travailler, il veut exécuter des instruction non-stop. Et si il arrive à la fin des instructions de notre Bootloader, il commencera à exécuter les instructions qui se trouvent juste après en mémoire, sauf que ce sont des valeurs aléatoires n'ayant aucun rapport, il va donc exécuter n'importe quoi et crasher.

Mais si on le bloque dans notre boucle infinie, il ne crashera pas :

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

Voilà, on a affiché la lettre "H" à l'écran. C'est bien hein... mais il nous manque 10 lettres... On pourrait juste copier-coller et puis c'est fait, mais faire ça c'est pas très propre. on préférera une autre méthode.

## Affichage de string complet

Pour afficher plusieurs caractères, on va utiliser le même système d'interruptions, mais dans une boucle, pour ne pas se répéter.

On va commencer par indiquer à l'ordinateur qu'on veut utiliser `bx` pour stocker l'adresse de `string`; en exécutant à partir de l'emplacement mémoire `0x7C00` :

```asm
[org 0x7C00]
mov bx, string
```

`string` qui contiendra une suite d'éléments d'1 octet dans la mémoire :

```asm
string db "Hello World", 0
```

> _💡 **Pour rappel :** `db` (define byte) définit une expression d'un octet_

On va ensuite écrire la fonction pour afficher un string :

```asm
print_string:
    mov al, [bx]
    cmp al, 0
    je done
    mov ah, 0x0E
    int 0x10
    inc bx
    jmp print_string
done :
    ret
```

Pas de panique, ça peut faire peur, mais détaillons chaque étape :

```asm
mov al, [bx]
```

Cette ligne ajoute la valeur du pointeur `[bx]` dans le registre `al` (si vous avez bien suivi, c'est celui où on stocke le caractère à afficher).

```asm
cmp al, 0
je done
```

Si la valeur de `al` est `0` (si on arrive à la fin du string), on termine l'exécution en appelant le fonction `done` (définie plus tard).

```asm
mov ah, 0x0E
    int 0x10
```

C'est comme tout à l'heure, on met `0x0E` dans le registre `ah`, puis on appelle l'interruption `0x10`.

```asm
inc bx
jmp print_string
```

On passe au caractère suivant et on recommence.

```asm
done :
    ret
```

Et on oublie pas de bien définir la fonction `done`, qui retourne et met fin au programme.

Nous avons donc un code complet qui ressemble à ça :

```asm
[org 0x7C00]
mov bx, string

print_string:
    mov al, [bx]
    cmp al, 0
    je done
    mov ah, 0x0E
    int 0x10
    inc bx
    jmp print_string
done :
    ret

string db "Hello World", 0

hang:
    jmp hang
times 510-($-$$) db 0
dw 0xAA55
```

Et voilà nous y sommes, _"Hello World"_ affiché fièrement sur notre fenêtre, en blanc sur fond noir.

# Mode protégé

Avant de booter notre OS, on doit d'abord passer en `mode protégé`.

En effet les fabricants de CPU sont obsédé par la rétrocompatibilité, ils veulent qu'un vieil OS préhistorique puisse tourner sans bug sur leur CPU dernier cri.

Pour faire ça, il faut émuler un vieux CPU. Donc quand on boot, notre CPU se comporte comme si il datait de 1978, c'est ce qu'on appelle le `mode réel` dans lequel on a par exemple moins d'1 mégaoctet de RAM disponible.

C'est pour ça qu'on doit nous même avancer le temps, en passant en `mode protégé`, amplement suffisant pour nous, car on a accès jusqu'à 4 gigaoctets de RAM.

Ce mode protégé nous permettra aussi, comme son nom l'indique, et protéger notre OS. Parce qu'en mode réel, il n'y a aucunes protections, n'importe quel logiciel peut faire tout ce qu'il veut.

Avec le mode protégé, on va pouvoir restreindre les applications extérieures, avec différents niveaux de privilèges appelées "rings".

La ring 0 est celle qu'utilisera notre OS et qui aura le plus de libertés, aucunes restrictions. Une application lambda sera de ring 3 avec très peu d'accès et si elle a besoin d'accéder à une ressource protégée, elle sera obligée de demander l'autorisation à l'OS.

On doit donc mettre en place des règles. Et c'est règles, c'est à nous de les définir pour les donner au CPU, avec la `GDT` (Global Description Table). Comme son nom l'indique, il s'agit d'une table qui va nous permettre de définir différents segments au sein de notre mémoire.

Chaque entrée de la table définit un de ses segments, comme l'adresse du début du segment, sa taille, puis certaines propriétés qu'on va lui donner comme si cette fonction peut être lue, modifiée, exécutée, quel niveau de privilèges...

| N°  | Début  | Taille |                                                                         Propriétés                                                                         |
| :-: | :----: | :----: | :--------------------------------------------------------------------------------------------------------------------------------------------------------: |
|  1  | 0x8000 | 0x1000 | Peut être <span style="color:green">**lue**</span>, <span style="color:red">**modifiée**</span>, <span style="color:green">**exécutée**</span>, **Ring 0** |
|  2  | 0x9000 | 0x2000 |   Peut être <span style="color:red">**lue**</span>, <span style="color:red">**modifiée**</span>, <span style="color:red">**exécutée**</span>, **Ring 3**   |
|  3  | 0xB000 | 0x5000 | Peut être <span style="color:green">**lue**</span>, <span style="color:green">**modifiée**</span>, <span style="color:red">**exécutée**</span>, **Ring 1** |

Et comme ça, tout est sécurisé.

Sauf que cette histoire de segmentation... ce n'est plus utilisé de nos jours, maintenant on fait du `paging`.

Mais malgré tout on doit définir une GDT, c'est obligatoire. Encore une histoire de rétrocompatibilité.

On va donc créer une GDT avec... aucune segmentations. C'est ce qu'on appelle le `Basic Flat Model`, qui consiste à ajouter 3 entrées dans la table GDT, les trois entrées obligatoires.

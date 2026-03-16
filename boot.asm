mov bx, string ; mettre le message dans le registre bx
call print_string

print_string:
    mov al, [bx] ; contient un caractère de notre string
    cmp al, 0 ; si vaut 0, fin de la string, on sort
    je done
    mov ah, 0x0E
    int 0x10
    inc bx ; on passe au caractère suivant
    jmp print_string ; on recommence pour afficher le string entier
done :
    ret ; fin de l'affichage

string db "Hello World", 0
hang:
    jmp hang
times 510-($-$$) db 0
dw 0xAA55
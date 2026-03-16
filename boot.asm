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
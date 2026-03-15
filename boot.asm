print_string:
    mov al, [bx]
    cmp al,
    je done
    mov ah, 0xΘΕ
    int 0x10
    add bx, 1
    jmp print_string
hang:
    jmp hang
times 510-($-$$) db 0
dw 0xAA55
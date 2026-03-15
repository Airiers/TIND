mov ah, 0x0E
mov al, 'H'
int 0x10
times 510-($-$$) dw 0
dw 0xAA55
mov ah, 0eh    ; teleprompt

mov al, 57h    ; W
int 10h        ; print
mov al, 65h    ; e
int 10h
mov al, 6ch    ; l
int 10h
mov al, 63h    ; c
int 10h
mov al, 6fh    ; o
int 10h
mov al, 6dh    ; m
int 10h
mov al, 65h    ; e
int 10h
mov al, 20h    ; space
int 10h
mov al, 74h    ; t
int 10h
mov al, 6fh    ; o
int 10h
mov al, 20h    ; space
int 10h
mov al, 4eh    ; N
int 10h
mov al, 65h    ; e
int 10h
mov al, 77h    ; w
int 10h
mov al, 63h    ; c
int 10h
mov al, 4fh    ; O
int 10h
mov al, 53h    ; S
int 10h
mov al, 21h    ; !
int 10h
mov al, 0ah    ; newline
int 10h
mov al, 0dh    ; CR
int 10h

times (510 - ($ - $$)) db 0   ; $: current offset
                              ; $$: address of the current section
                              ; for whatever reason, nasm says (510 - $) is not a constant
dw 0xaa55

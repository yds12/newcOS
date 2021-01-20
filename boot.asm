bits 16
org 0x7c00

; where to load the Kernel to
KERNEL_OFFSET equ 0x1000
;KERNEL_OFFSET equ 0x9c00

; BIOS set the boot drive in dl, store for later
;mov [BOOT_DRIVE], dl

; DEBUG
; BOOT_DRIVE is being set to 128 (0x80) which is the common
; value for HDD

; Idk what this does
; maybe clearing segment registers
;mov ax, cs
;mov ds, ax
;mov es, ax
;mov ss, ax

; setup a temporary stack
mov bp, 0x9000 ; 7c00
mov sp, bp

; setup video mode
mov ah, 0x00
mov al, 0x03      ; 80x25 text
int 0x10

;mov bx, 0x7c00
;call mem_dump
;jmp $

; print welcome msg
mov si, msg_hello
call print

; DEBUG (write to video)
;mov ax, 0xb800
;mov es, ax
;mov ax, 0x4061
;mov word [es:0x0000], ax 
;jmp $

; reset disk
xor ah, ah
;mov dl, [BOOT_DRIVE]
int 0x13
jc reset_error 
jmp ok

reset_error:
  mov si, msg_disk_reset_err
  call print
  jmp $

ok:
;  mov si, msg_disk_reset_ok
;  call print

; load Kernel
;mov dl, [BOOT_DRIVE]   ; store boot drive in dl

; disk load
;pusha
;push dx

mov ah, 0x02   ; read mode
mov al, 0x01   ; number of sectors to read
mov ch, 0x00   ; cylinder 0
mov cl, 0x02   ; sector 2 (sector 1 is the boot sector)
mov dh, 0x00   ; head 0
mov bx, KERNEL_OFFSET  ; bx is destination
mov es, bx
xor bx, bx     ; KERNEL_OFFSET:0x0000

; dl should be the drive number
; es:bx should be a pointer to the buffer where to store the read content

int 0x13       ; BIOS interrupt: read disk

; DEBUG
; this interrupt is resulting in error (carry flag set)
; and the return code (in ah) is 12 (0x0C = media type not found)

jc disk_error  ; error will set the carry (jc = jump if carry)

;pop dx         ; get back the number of sectors to read
cmp al, 0x01 ;dh     ; compare with al (sectors read)

jne disk_error_amount ; if not equal, error
;popa

mov si, msg_disk_read_ok
call print
call check_kernel_mem

; DEBUG
;jmp KERNEL_OFFSET:0x0000

call prepare32
jmp $ ; infinite loop

disk_error:
  mov si, msg_disk_err
  call print
  jmp $

disk_error_amount:
  mov si, msg_disk_amount_err
  call print
  jmp $

check_kernel_mem:
  mov bx, KERNEL_OFFSET
  call mem_dump
  jmp $

  mov al, 0xe8
  cmp al, [KERNEL_OFFSET]
  jne .err
  mov al, 0x02
  cmp al, [KERNEL_OFFSET + 1]
  jne .err
  ret
.err:
  mov si, msg_kernel_not_ok
  call print
  jmp $

; %include "gdt.asm"

; GDT: global descriptor table
; we are using a GDT with a null descriptor plus a code and a data segment,
; each covering the full 4GB (and overlapping)

; null segment descriptor
gdt_start:
  dq 0x0   ; 8 bytes

; code segment descriptor
gdt_code:
  dw 0xffff     ; segment length, bits 0-15
  dw 0x0        ; segment base, bits 0-15
  db 0x0        ; segment base, bits 16-23
  db 10011010b  ; flags (8 bits)
  db 11001111b  ; flags (4 bits) + segment length, bits 16-19
  db 0x0        ; segment base, bits 24-31

; data segment descriptor
gdt_data:
  dw 0xffff     ; same as previous segment
  dw 0x0
  db 0x0
  db 10010010b
  db 11001111b
  db 0x0

gdt_end:

; GDT descriptor
gdt_descriptor:
  dw gdt_end - gdt_start - 1   ; size (16 bit)
  dd gdt_start                 ; address (32 bit)

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

print:
  mov ah, 0x0e           ; int 0x10 ah=0x0e (putchar)
.loop:
  lodsb                  ; load string byte from si
  or al, al              ; check if al is 0 (null char)
  jz .end
  int 0x10               ; bios print interruption
  jmp .loop              ; print the other chars
.end:
  ret

print_byte: ; byte in al
  push ax
  lea bx, [chars]
  and ax, 0x00F0
  shr ax, 4
  mov si, ax
  mov al, byte [bx + si]
  mov ah, 0x0e
  int 0x10
  pop ax
  and ax, 0x000F
  mov si, ax
  mov al, byte [bx + si]
  mov ah, 0x0e
  int 0x10
  ret

mem_dump:  ; address in bx
  mov di, 0
  mov es, bx
.loop:
  xor bx, bx
  mov al, byte [es:bx + di]
  call print_byte
  inc di
  xor bx, bx
  mov al, byte [es:bx + di]
  call print_byte
  inc di
  mov ah, 0x0e
  mov al, " "
  int 0x10
  cmp di, 512
  jne .loop
  ret

mem_dump_no_seg:  ; address in bx
  mov di, 0
.loop:
  mov es, bx
  xor bx, bx
  mov al, byte [es:bx + di]
  push bx
  call print_byte
  pop bx
  inc di
  xor bx, bx
  mov al, byte [es:bx + di]
  push bx
  call print_byte
  pop bx
  inc di
  mov ah, 0x0e
  mov al, " "
  int 0x10
  cmp di, 512
  jne .loop
  ret


chars: db "0123456789ABCDEF"
msg_hello: db "== NewcOS ==", 0x0a, 0x0a, 0x0d, 0
msg_disk_reset_err: db "ERR1", 0x0a, 0x0d, 0
msg_disk_reset_ok: db "OK1", 0x0a, 0x0d, 0
msg_disk_err: db "ERR2", 0x0a, 0x0d, 0
msg_disk_amount_err: db "ERR3", 0x0a, 0x0d, 0
msg_disk_read_ok: db "OK2", 0x0a, 0x0d, 0
msg_kernel_not_ok: db "ERR4", 0x0a, 0x0d, 0

prepare32:
  cli                      ; disable BIOS interrupts
  lgdt [gdt_descriptor]    ; load GDT

  ; enable protected mode
  mov eax, cr0
  or  al, 1
  mov cr0, eax

  jmp CODE_SEG:start32  ; far jump

bits 32
start32:
  mov ax, DATA_SEG       ; update segment registers
  mov ds, ax
  mov ss, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  mov ebp, 0x90000       ; setup another stack
  mov esp, ebp

  call KERNEL_OFFSET     ; give control to Kernel
  jmp $                  ; loop if kernel returns

;BOOT_DRIVE db 0

; padding
times (510 - ($ - $$)) db 0   ; $: current offset
                              ; $$: address of the current section
                              ; for whatever reason, nasm says (510 - $) is not a constant
dw 0xaa55  ; magic word


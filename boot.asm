bits 16      ; 16 bit instructions
org 0x7c00   ; assume program will be loaded here

; address where the kernel should be loaded in memory
; (this will go to the segment register, so the actual
; address is this times 16)
KERNEL_OFFSET equ 0x1000

; setup a temporary stack (for push, call, ret, etc.)
mov bp, 0x9000
mov sp, bp

; setup video mode
mov ah, 0x00
mov al, 0x03      ; 80x25 text
int 0x10          ; BIOS interrupt

; print welcome msg
mov si, msg_hello
call print

; reset disk
xor ah, ah
int 0x13
jc reset_error 
jmp ok

reset_error:
  mov si, msg_disk_reset_err
  call print
  jmp $

ok:
  mov si, msg_disk_reset_ok
  call print

; Read the kernel from the disk

; dl should be the drive number
; dl is being set by the BIOS to 128 (0x80) which
; is the common value for HDD

mov ah, 0x02   ; read mode
mov al, 0x01   ; number of sectors to read
mov ch, 0x00   ; cylinder 0
mov cl, 0x02   ; sector 2 (sector 1 is the boot sector)
mov dh, 0x00   ; head 0

; es:bx should be a pointer to the buffer where to store the read content
mov bx, KERNEL_OFFSET
mov es, bx
xor bx, bx     ; KERNEL_OFFSET:0x0000

int 0x13       ; BIOS interrupt: read disk
jc disk_error  ; error will set the carry (jc = jump if carry)

cmp al, 0x01          ; compare with al (sectors read) with desired number
jne disk_error_amount ; if not equal, error

mov si, msg_disk_read_ok
call print

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

chars: db "0123456789ABCDEF"
msg_hello: db "> NewcOS booting...", 0x0a, 0x0d, 0
msg_disk_reset_err: db "> Error reseting disk.", 0x0a, 0x0d, 0
msg_disk_reset_ok: db "> Disk successfully reset.", 0x0a, 0x0d, 0
msg_disk_err: db "> Disk error.", 0x0a, 0x0d, 0
msg_disk_amount_err: db "> Could not read all required sectors.", 0x0a, 0x0d, 0
msg_disk_read_ok: db "> Disk successfully read.", 0x0a, 0x0d, 0

prepare32:
  cli                      ; disable BIOS interrupts
  lgdt [gdt_descriptor]    ; load GDT

  ; enable protected mode
  mov eax, cr0
  or  al, 1
  mov cr0, eax

  jmp CODE_SEG:start32  ; far jump

; from here on, 32 bit instructions
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

; Since now we are in a flat memory mode,
; an address xxx:0x0000 becomes xxx*16
; (the real memory address is the value of the segment multiplied by 
; 16 and added to the offset)
  call KERNEL_OFFSET * 16  ; give control to Kernel
  jmp $                    ; loop if kernel returns

; padding
times (510 - ($ - $$)) db 0   ; $: current offset
                              ; $$: address of the current section
                              ; for whatever reason, nasm says (510 - $) is not a constant
dw 0xaa55  ; magic word


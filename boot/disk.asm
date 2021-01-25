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

; We are now padding the image to 48KB of size, so we can
; read 0x5F sectors without causing errors (0x6 - 1 for the boot sector).
IMG_NUM_SECTORS equ 0x5E ; almost 48KB

mov ah, 0x02   ; read mode
mov al, IMG_NUM_SECTORS  ; number of sectors to read
mov ch, 0x00   ; cylinder 0
mov cl, 0x02   ; sector 2 (sector 1 is the boot sector)
mov dh, 0x00   ; head 0

; es:bx should be a pointer to the buffer where to store the read content
mov bx, KERNEL_OFFSET
mov es, bx
xor bx, bx     ; KERNEL_OFFSET:0x0000

int 0x13       ; BIOS interrupt: read disk
jc disk_error  ; error will set the carry (jc = jump if carry)

cmp al, IMG_NUM_SECTORS  ; compare with al (sectors read) with desired number
jne disk_error_amount ; if not equal, error

mov si, msg_disk_read_ok
call print
call end_disk

disk_error:
  mov si, msg_disk_err
  call print
  jmp $

disk_error_amount:
  mov si, msg_disk_amount_err
  call print
  jmp $

end_disk:


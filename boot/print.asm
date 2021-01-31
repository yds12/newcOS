jmp end_print

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

msg_hello: db "> NewcOS booting...", 0x0a, 0x0d, 0
msg_disk_reset_err: db "> Disk reset err.", 0x0a, 0x0d, 0
msg_disk_reset_ok: db "> Disk reset OK.", 0x0a, 0x0d, 0
msg_disk_err: db "> Disk err.", 0x0a, 0x0d, 0
msg_disk_amount_err: db "> Num sectors read err.", 0x0a, 0x0d, 0
msg_disk_read_ok: db "> Disk read OK.", 0x0a, 0x0d, 0
msg_mmap_err: db "> MMAP err.", 0x0a, 0x0d, 0
msg_mmap_ok: db "> MMAP OK.", 0x0a, 0x0d, 0
end_print:


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


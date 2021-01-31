MEMTAB equ 0xC000
MAGIC equ 0x0534D4150

rm_mmap:
  xor ax, ax
  mov es, ax
  mov di, MEMTAB + 4
  xor ebx, ebx                ; start with ebx = 0
  xor bp, bp                  ; entry count
  mov edx, MAGIC              ; magic number
  mov eax, 0xE820             ; memory map operation
  mov [es:di + 20], dword 1   ; ??
  mov ecx, 24                 ; ask for 24 bytes
  int 0x15                    ; the BIOS interruption that does the job
  jc short .failed            ; carry set on first call: unsupported function
  mov edx, MAGIC              ; might have been trashed
  cmp eax, edx                ; on success EAX will have magic number
  jne short .failed
  test ebx, ebx               ; ebx=0 means list is 1 entry long
  je short .failed
  jmp short .jmpin
.loop:                        ; this is being called 5 times (DEBUG)
  mov eax, 0xe820
  mov [es:di + 20], dword 1
  mov ecx, 24
  int 0x15
  jc short .end
  mov edx, MAGIC
.jmpin:
  jcxz .skipentry             ; skip 0 length entry
  cmp cl, 20                  ; got a 24 byte response?
  jbe short .notext
  test byte [es:di + 20], 1
  je short .skipentry
.notext:
  mov ecx, [es:di + 8]        ; lower 32 bits of mem. region length
  or ecx, [es:di + 12]        ; OR with upper 32 bits to test for 0
  jz .skipentry
  inc bp                      ; good entry, next
  add di, 24
.skipentry:
  test ebx, ebx               ; if EBX is reset to 0, list is complete
  jne short .loop
.end:
  mov [MEMTAB], bp
  clc                         ; clear carry
  jmp end_function
.failed:
  mov si, msg_mmap_err
  call print
  jmp $

end_function:
  mov si, msg_mmap_ok
  call print


; IRQ: Interrupt Request
bits 32

extern irq_handler

global irq0
global irq1
global irq2
global irq3
global irq4
global irq5
global irq6
global irq7
global irq8
global irq9
global irq10
global irq11
global irq12
global irq13
global irq14
global irq15

; IRQ handlers
irq0:
  push byte 0
  push byte 32
  jmp irq_common

irq1:
  push byte 1
  push byte 33
  jmp irq_common

irq2:
  push byte 2
  push byte 34
  jmp irq_common

irq3:
  push byte 3
  push byte 35
  jmp irq_common

irq4:
  push byte 4
  push byte 36
  jmp irq_common

irq5:
  push byte 5
  push byte 37
  jmp irq_common

irq6:
  push byte 6
  push byte 38
  jmp irq_common

irq7:
  push byte 7
  push byte 39
  jmp irq_common

irq8:
  push byte 8
  push byte 40
  jmp irq_common

irq9:
  push byte 9
  push byte 41
  jmp irq_common

irq10:
  push byte 10
  push byte 42
  jmp irq_common

irq11:
  push byte 11
  push byte 43
  jmp irq_common

irq12:
  push byte 12
  push byte 44
  jmp irq_common

irq13:
  push byte 13
  push byte 45
  jmp irq_common

irq14:
  push byte 14
  push byte 46
  jmp irq_common

irq15:
  push byte 15
  push byte 47
  jmp irq_common

irq_common:  ; similar to isr_common
  ; save CPU state
  pusha
  mov ax, ds
  push eax
  mov ax, 0x10
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  ; call C handler
  push esp
  call irq_handler
  pop ebx

  ; restore state
  pop ebx
  mov ds, bx
  mov es, bx
  mov fs, bx
  mov gs, bx
  popa
  add esp, 8
  iret


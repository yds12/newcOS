; ISR: Interrupt Service Routines
bits 32

; We need different handlers for every interrupt because
; we don't get information about the interrupt number.
; Some interrupts push an error code onto the stack, so
; for those which don't, we push a 0 to keep the stack consistent.

extern isr_handler

global isr0
global isr1
global isr2
global isr3
global isr4
global isr5
global isr6
global isr7
global isr8
global isr9
global isr10
global isr11
global isr12
global isr13
global isr14
global isr15
global isr16
global isr17
global isr18
global isr19
global isr20
global isr21
global isr22
global isr23
global isr24
global isr25
global isr26
global isr27
global isr28
global isr29
global isr30
global isr31

isr0:
  push byte 0
  push byte 0
  jmp isr_common

isr1:
  push byte 0
  push byte 1
  jmp isr_common

isr2:
  push byte 0
  push byte 2
  jmp isr_common

isr3:
  push byte 0
  push byte 3
  jmp isr_common

isr4:
  push byte 0
  push byte 4
  jmp isr_common

isr5:
  push byte 0
  push byte 5
  jmp isr_common

isr6:
  push byte 0
  push byte 6
  jmp isr_common

isr7:
  push byte 0
  push byte 7
  jmp isr_common

isr8:
  push byte 8
  jmp isr_common

isr9:
  push byte 0
  push byte 9
  jmp isr_common

isr10:
  push byte 10
  jmp isr_common

isr11:
  push byte 11
  jmp isr_common

isr12:
  push byte 12
  jmp isr_common

isr13:
  push byte 13
  jmp isr_common

isr14:
  push byte 14
  jmp isr_common

isr15:
  push byte 0
  push byte 15
  jmp isr_common

isr16:
  push byte 0
  push byte 16
  jmp isr_common

isr17:
  push byte 0
  push byte 17
  jmp isr_common

isr18:
  push byte 0
  push byte 18
  jmp isr_common

isr19:
  push byte 0
  push byte 19
  jmp isr_common

isr20:
  push byte 0
  push byte 20
  jmp isr_common

isr21:
  push byte 0
  push byte 21
  jmp isr_common

isr22:
  push byte 0
  push byte 22
  jmp isr_common

isr23:
  push byte 0
  push byte 23
  jmp isr_common

isr24:
  push byte 0
  push byte 24
  jmp isr_common

isr25:
  push byte 0
  push byte 25
  jmp isr_common

isr26:
  push byte 0
  push byte 26
  jmp isr_common

isr27:
  push byte 0
  push byte 27
  jmp isr_common

isr28:
  push byte 0
  push byte 28
  jmp isr_common

isr29:
  push byte 0
  push byte 29
  jmp isr_common

isr30:
  push byte 0
  push byte 30
  jmp isr_common

isr31:
  push byte 0
  push byte 31
  jmp isr_common

isr_common:
  ; save CPU state
  pusha
  mov ax, ds
  push eax      ; save segment
  mov ax, 0x10  ; kernel data segment descriptor
  mov ds, ax    ; set segment
  mov es, ax
  mov fs, ax
  mov gs, ax

  ; call C handler
  push esp
  call isr_handler
  pop eax

  ; restore state
  pop eax
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  popa
  add esp, 8    ; cleans up pushed error code and ISR number
  iret          ; pops: cs, eip, eflags, ss and esp

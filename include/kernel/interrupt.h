#pragma once

#include <stdint.h>

#define KERNEL_SEG 0x08
#define IDT_ENTRIES 256

// A interrupt gate (handler)
typedef struct {
  uint16_t low_offset;  // lower bits of handler function address
  uint16_t selector;    // kernel segment selector
  uint8_t filler;       // always 0
  uint8_t flags;
  uint16_t high_offset; // high bits of handler function
} __attribute__((packed)) idt_gate;

// Pointer to the IDT, loaded with lidt
typedef struct {
  uint16_t limit;
  uint32_t base;
} __attribute__((packed)) idt_register;

typedef struct {
  uint32_t ds;
  uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;  // pushed by pusha
  uint32_t int_num, err_code;
  uint32_t eip, cs, eflags, useresp, ss;            // pushed automatically
} registers;

void set_idtgate(int n, uint32_t handler);
void load_idt();


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
void isr_setup();

extern void isr0();
extern void isr1();
extern void isr2();
extern void isr3();
extern void isr4();
extern void isr5();
extern void isr6();
extern void isr7();
extern void isr8();
extern void isr9();
extern void isr10();
extern void isr11();
extern void isr12();
extern void isr13();
extern void isr14();
extern void isr15();
extern void isr16();
extern void isr17();
extern void isr18();
extern void isr19();
extern void isr20();
extern void isr21();
extern void isr22();
extern void isr23();
extern void isr24();
extern void isr25();
extern void isr26();
extern void isr27();
extern void isr28();
extern void isr29();
extern void isr30();
extern void isr31();


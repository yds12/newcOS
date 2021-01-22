#include <stdint.h>
#include "kernel/interrupt.h"

#define lo16(addr) (uint16_t)((addr) & 0xffff)
#define hi16(addr) (uint16_t)(((addr) >> 16) & 0xffff)

void isr_handler(registers* r) {
  // r->int_num for interrupt number
  char* vmem = (char*) 0xb8000;
  vmem[80 * 7 * 2] = '+';
  vmem[80 * 7 * 2 + 1] = 0xe1;
}

void irq_handler(registers* r) {
  // r->int_num for interrupt number
  char* vmem = (char*) 0xb8000;
  vmem[80 * 8 * 2] = '*';
  vmem[80 * 8 * 2 + 1] = 0xe1;
}

idt_gate idt[256];

void set_idt_gate(int gate_num, uint32_t handler) {
  idt[gate_num].low_offset = lo16(handler);
  idt[gate_num].selector = 0x08; // from GDT
  idt[gate_num].filler = 0;
  idt[gate_num].flags = 0x8e; // 1 00 0 1 110 (P DPL 0 D type)
  idt[gate_num].high_offset = hi16(handler);
}

void isr_setup() {
  set_idt_gate(0, (uint32_t) isr0);
  set_idt_gate(1, (uint32_t) isr1);
  set_idt_gate(2, (uint32_t) isr2);
  set_idt_gate(3, (uint32_t) isr3);
  set_idt_gate(4, (uint32_t) isr4);
  set_idt_gate(5, (uint32_t) isr5);
  set_idt_gate(6, (uint32_t) isr6);
  set_idt_gate(7, (uint32_t) isr7);
  set_idt_gate(8, (uint32_t) isr8);
  set_idt_gate(9, (uint32_t) isr9);
  set_idt_gate(10, (uint32_t) isr10);
  set_idt_gate(11, (uint32_t) isr11);
  set_idt_gate(12, (uint32_t) isr12);
  set_idt_gate(13, (uint32_t) isr13);
  set_idt_gate(14, (uint32_t) isr14);
  set_idt_gate(15, (uint32_t) isr15);
  set_idt_gate(16, (uint32_t) isr16);
  set_idt_gate(17, (uint32_t) isr17);
  set_idt_gate(18, (uint32_t) isr18);
  set_idt_gate(19, (uint32_t) isr19);
  set_idt_gate(20, (uint32_t) isr20);
  set_idt_gate(21, (uint32_t) isr21);
  set_idt_gate(22, (uint32_t) isr22);
  set_idt_gate(23, (uint32_t) isr23);
  set_idt_gate(24, (uint32_t) isr24);
  set_idt_gate(25, (uint32_t) isr25);
  set_idt_gate(26, (uint32_t) isr26);
  set_idt_gate(27, (uint32_t) isr27);
  set_idt_gate(28, (uint32_t) isr28);
  set_idt_gate(29, (uint32_t) isr29);
  set_idt_gate(30, (uint32_t) isr30);
  set_idt_gate(31, (uint32_t) isr31);

  // Initialize Command Word (ICW) 1
  port_byte_out(0x20, 0x11);
  port_byte_out(0xA0, 0x11);

  // ICW2
  port_byte_out(0x21, 0x20);
  port_byte_out(0xA1, 0x28);

  // ICW3
  port_byte_out(0x21, 0x04);
  port_byte_out(0xA1, 0x02);

  // ICW4
  port_byte_out(0x21, 0x01);
  port_byte_out(0xA1, 0x01);

  // Operational Command Word (OCW) 1
  port_byte_out(0x21, 0);
  port_byte_out(0xA1, 0);
}


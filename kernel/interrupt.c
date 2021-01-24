#include <stdint.h>
#include "kernel/interrupt.h"
#include "drivers/ioports.h"

#define lo16(addr) (uint16_t)((addr) & 0xffff)
#define hi16(addr) (uint16_t)(((addr) >> 16) & 0xffff)

// ports:
// 0x20 primary PIC (PIC1) command and status register
#define PIC1_CTRL 0x20
// 0xA0 secondary PIC (PIC2) comm. and status reg.
#define PIC2_CTRL 0xa0
// 0x21 PIC1 interrupt mask reg. and data reg.
#define PIC1_DATA 0x21
// 0xA1 PIC2 int. mask reg. and data reg.
#define PIC2_DATA 0xa1

idt_gate idt[IDT_ENTRIES];
idt_register idt_reg;

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

  // Send an End of Interrupt (EOI) to PICs
  port_byte_out(PIC1_CTRL, 0x20); // primary PIC EOI
  if(r->int_num < 40) {
    port_byte_out(PIC2_CTRL, 0x20); // secondary PIC EOI
  }
}

void set_idt_gate(int gate_num, uint32_t handler) {
  idt[gate_num].low_offset = lo16(handler);
  idt[gate_num].selector = 0x08; // from GDT
  idt[gate_num].filler = 0;
  idt[gate_num].flags = 0x8e; // 1 00 0 1 110 (P DPL 0 D type)
  idt[gate_num].high_offset = hi16(handler);
}

void load_idt() {
  idt_reg.base = (uint32_t) &idt;
  idt_reg.limit = IDT_ENTRIES * sizeof(idt_gate) - 1;
  asm volatile("lidt (%0)" : : "r" (&idt_reg));
}

void pic_remap() {
  // Initialize Command Word (ICW) 1
  port_byte_out(PIC1_CTRL, 0x11); // init PIC1, expect ICW4
  port_byte_out(PIC2_CTRL, 0x11); // init PIC2, expect ICW4

  // ICW2
  // Here we map which blocks of the IDT will be mapped
  // to each of the PICs. Entries 0 to 31 are reserved, so:
  port_byte_out(PIC1_DATA, 0x20); // set IDT offset to 32 for PIC1
  port_byte_out(PIC2_DATA, 0x28); // set IDT offset to 40 for PIC2

  // ICW3
  // For PIC1, we must send 8 bits, all 0s and 1 in the bit
  // position representing the line that will connect to PIC2
  // in this case, line IR2 which is bit 2, so 0100 = 0x04
  port_byte_out(PIC1_DATA, 0x04);
  // For PIC2 we just send a 3 bit number representing the
  // number of the line, in this case IR2 so 10 in binary (0x02)
  port_byte_out(PIC2_DATA, 0x02); // redirection to IRQ2

  // ICW4
  port_byte_out(PIC1_DATA, 0x01); // enables 80x86 mode (?)
  port_byte_out(PIC2_DATA, 0x01);

  // Operational Command Word (OCW) 1
  //port_byte_out(PIC1_DATA, 0); // all done, clear data
  //port_byte_out(PIC2_DATA, 0);
  port_byte_out(PIC1_DATA, 0xfd); // only IRQ1 (keyboard)
  port_byte_out(PIC2_DATA, 0xff);
}

void idt_setup() {
  // Internal ISRs (CPU exceptions)
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

  pic_remap();

  // IRQ ISRs (primary PIC)
  set_idt_gate(32, (uint32_t) irq0);
  set_idt_gate(33, (uint32_t) irq1);
  /*
  // for now we just need IRQ1 = keyboard
  set_idt_gate(34, (uint32_t) irq2);
  set_idt_gate(35, (uint32_t) irq3);
  set_idt_gate(36, (uint32_t) irq4);
  set_idt_gate(37, (uint32_t) irq5);
  set_idt_gate(38, (uint32_t) irq6);
  set_idt_gate(39, (uint32_t) irq7);

  // IRQ ISRs (secondary PIC)
  set_idt_gate(40, (uint32_t) irq8);
  set_idt_gate(41, (uint32_t) irq9);
  set_idt_gate(42, (uint32_t) irq10);
  set_idt_gate(43, (uint32_t) irq11);
  set_idt_gate(44, (uint32_t) irq12);
  set_idt_gate(45, (uint32_t) irq13);
  set_idt_gate(46, (uint32_t) irq14);
  set_idt_gate(47, (uint32_t) irq15);
  */

  load_idt();
}


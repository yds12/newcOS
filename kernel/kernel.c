#include "util.h"
#include "driver/vga.h"
#include "driver/keyboard.h"
#include "kernel/interrupt.h"

void kmain() {
  print("> Hello from NewcOS kernel!\n");

  idt_setup();
  asm volatile("sti");  // enable external interrupts
  init_kb();
  while(1) asm("hlt");
}


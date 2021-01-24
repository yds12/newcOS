#include "util.h"
#include "drivers/vga.h"
#include "kernel/interrupt.h"

void kmain() {
  //char text[27] = "> Hello from NewcOS kernel!";
  //println(text);
  println("> Hello from NewcOS kernel!");
  newline();
  memdump((void*) 0x7c00, 512);
  //memdump((void*) (0x1000 * 16 + 0x904), 512);

  idt_setup();
  asm volatile("sti");  // enable external interrupts
  while(1) asm("hlt");
}


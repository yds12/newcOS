#include "util.h"
#include "driver/vga.h"
#include "driver/keyboard.h"
#include "kernel/interrupt.h"
#include "kernel/mmap.h"
#include "kernel/vmm.h"

extern void* rm_mmap();

void kmain() {
  print("> NewcOS kernel started!\n");
  void* memtable = (void*) 0xC004;
  print("> Memory map in: ");
  print_addr(memtable);
  print("\n");
//  memdump(memtable, 256);
  load_bios_mmap(memtable);

  idt_setup();
  asm volatile("sti");  // enable external interrupts
  init_kb();
  vmm_init();
  while(1) asm("hlt");
}


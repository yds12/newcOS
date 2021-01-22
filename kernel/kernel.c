#include "drivers/ioports.h"
#include "kernel/interrupt.h"

#define VIDEO_MEM_ADD 0xb8000
#define VGA_CTRL_REG 0x3d4
#define VGA_DATA_REG 0x3d5
#define VGA_OFFSET_LO 0x0f
#define VGA_OFFSET_HI 0x0e

void set_cursor(short offset) {
  port_byte_out(VGA_CTRL_REG, VGA_OFFSET_HI);
  port_byte_out(VGA_DATA_REG, (unsigned char) (offset >> 8));
  port_byte_out(VGA_CTRL_REG, VGA_OFFSET_LO);
  port_byte_out(VGA_DATA_REG, (unsigned char) (offset & 0xff));
}

short get_cursor() {
  port_byte_out(VGA_CTRL_REG, VGA_OFFSET_HI);
  short offset = port_byte_in(VGA_DATA_REG) << 8;
  port_byte_out(VGA_CTRL_REG, VGA_OFFSET_LO);
  offset += port_byte_in(VGA_DATA_REG);
  return offset;
}

void kmain() {
  short offset = 80 * 3;
  char text[27] = "> Hello from NewcOS kernel!";
  char color = 0xE1;
  char* video_mem = (char*) VIDEO_MEM_ADD;

  for(char i = 0; text[i] != 0; i++) {
    video_mem[offset * 2 + i * 2] = text[i];
    video_mem[offset * 2 + i * 2 + 1] = color;
  }

  set_cursor(80 * 4);
  short cursor = get_cursor();
  set_cursor(cursor + 1);

  isr_setup();
  asm volatile("sti");  // enable external interrupts
  while(1);
}


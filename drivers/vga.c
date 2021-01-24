#include "drivers/vga.h"
#include "drivers/ioports.h"

#define VIDEO_MEM_ADDR 0xb8000
#define VGA_CTRL_REG 0x3d4
#define VGA_DATA_REG 0x3d5
#define VGA_OFFSET_LO 0x0f
#define VGA_OFFSET_HI 0x0e
#define VGA_COLS 80
#define VGA_ROWS 25
#define DEFAULT_COLOR 0x07

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

int strlen(char* text) {
  int len = 0;

  while(text[len] != 0) len++;
  return len;
}

void print_byte(uint8_t byte) {
  uint8_t* video_mem = (uint8_t*) VIDEO_MEM_ADDR;
  short cursor = get_cursor();
  uint8_t digits[16] = "0123456789ABCDEF";

  video_mem[cursor * 2] = digits[hi_nib(byte)];
  video_mem[cursor * 2 + 1] = DEFAULT_COLOR;
  video_mem[cursor * 2 + 2] = digits[lo_nib(byte)];
  video_mem[cursor * 2 + 3] = DEFAULT_COLOR;
  set_cursor(cursor + 2);
}

void memdump(const void* address, uint32_t length) {
  for(int i = 0; i < length; i++) {
    print_byte(((uint8_t*) address)[i]);

    if(i % 2 == 1) set_cursor(get_cursor() + 1);
  }
}

void newline() {
  short cursor = get_cursor();
  set_cursor(cursor + (VGA_COLS - (cursor % VGA_COLS)));
}

void println(char* text) {
  char color = 0xE1;
  short cursor = get_cursor();
  char* video_mem = (char*) VIDEO_MEM_ADDR;

  short i = 0;
  for(; text[i] != 0; i++) {
    video_mem[cursor * 2 + i * 2] = text[i];
    video_mem[cursor * 2 + i * 2 + 1] = color;
  }

  short new_cursor = cursor + i - 1;

  if(new_cursor % VGA_COLS == 0) set_cursor(cursor + i - 1);
  else newline();
}


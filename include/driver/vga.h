#ifndef NEWCOS_DRIVER_VGA_H
#define NEWCOS_DRIVER_VGA_H

#include "util.h"

void set_cursor(short offset);
short get_cursor();
void printch(char ch);
void print(char* text);
void print_byte(uint8_t byte);
void print_int32(uint32_t num);
void print_int64(uint64_t num);
const void* print_addr(const void* ptr);
void memdump(const void* address, uint32_t length);

#endif

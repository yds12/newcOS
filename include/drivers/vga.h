#pragma once
#include "util.h"

void set_cursor(short offset);
short get_cursor();
void println(char* text);
void newline();
void print_byte(uint8_t byte);
void memdump(const void* address, uint32_t length);


#pragma once
#include "util.h"

void set_cursor(short offset);
short get_cursor();
void printch(char ch);
void print(char* text);
void print_byte(uint8_t byte);
void* print_addr(void* ptr);
void memdump(const void* address, uint32_t length);


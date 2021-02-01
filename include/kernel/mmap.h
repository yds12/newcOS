#pragma once

#include "util.h"

typedef struct st_bios_mmap_entry {
  uint64_t base_addr;
  uint64_t length;
  uint32_t type;
  uint32_t extended_attrs;
}__attribute__((packed)) bios_mmap_entry;

void load_bios_mmap(void* addr);


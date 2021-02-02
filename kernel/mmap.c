#include "kernel/mmap.h"
#include "driver/vga.h"

#define MAX_MMAP_ENTRIES 20

void load_bios_mmap(void* addr) {
  bios_mmap_entry entries[MAX_MMAP_ENTRIES];
  char nentries = 0;

  for(int i = 0; i < MAX_MMAP_ENTRIES; i++) {
    entries[i] = ((bios_mmap_entry*) addr)[i];

    if(entries[i].length == 0) {
      nentries = i;
      break;
    }
  }

  uint64_t mem_total = 0;
  uint64_t mem_usable = 0;
  uint64_t mem_reserved = 0;

  for(int i = 0; i < nentries; i++) {
    bios_mmap_entry entry = entries[i];
    print("Entry ");
    print_byte((uint8_t) i);
    print(": base (");
    print_int64(entry.base_addr);
    print(")");
    print(", len (");
    print_int64(entry.length);
    print("), ");

    if(entry.type == 1) {
      print("usable");
      mem_usable += entry.length;
    } else if(entry.type == 2) {
      print("reserved");
      mem_reserved += entry.length;
    }
    //print(", ext (");
    //print_int32(entry.extended_attrs);
    //print(")"); 
    print("\n");

    mem_total += entry.length;
  }

  print("reserved memory: ");
  print_int64(mem_reserved);
  print("\n");
  print("usable memory:   ");
  print_int64(mem_usable);
  print("\n");
  print("total memory:    ");
  print_int64(mem_total);
  print("\n");
}


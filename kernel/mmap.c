#include "kernel/mmap.h"
#include "driver/keyboard.h"

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

  for(int i = 0; i < nentries; i++) {
    bios_mmap_entry entry = entries[i];
    print("Entry ");
    print_byte((uint8_t) i);
    print(": base (");
    print_int64(entry.base_addr);
    print(")");
    print(", len (");
    print_int64(entry.length);
    print(")");
    print(", type (");

    if(entry.type == 1) print("usable");
    else if(entry.type == 2) print("reserved");
    print(")");
    //print(", ext (");
    //print_int32(entry.extended_attrs);
    //print(")"); 
    print("\n");
  }
}


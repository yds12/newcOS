#include "util.h"

uint32_t page_dir[1024] __attribute__((aligned(4096)));
uint32_t page_table_one[1024] __attribute__((aligned(4096)));
uint32_t page_table_two[1024] __attribute__((aligned(4096)));
uint32_t page_table_three[1024] __attribute__((aligned(4096)));

// assembly functions
extern void load_page_dir(uint32_t* page_dir_addr);
extern void enable_paging();

void create_page_dir() {
  // This sets the following flags to the pages:
  // * supervisor: Only kernel-mode can access them
  // * write enabled: It can be both read from and written to
  // * not present: The page table is not present
  for(int i = 0; i < 1024; i++) page_dir[i] = 0x00000002;
}

void vmm_init() {
  create_page_dir();

  // identity map the first page table
  // attributes: supervisor, read/write, present
  for(int i = 0; i < 1024; i++) page_table_one[i] = (i * 0x1000) | 0x03;

  // second page is mapped somewhere else
  // attributes: supervisor, read/write, present
  uint32_t offset = 1024 * 4096 * 2;
  for(int i = 0; i < 1024; i++) page_table_two[i] = (offset + i * 0x1000) | 0x03;

  // third page is identity mapped
  for(int i = 0; i < 1024; i++) page_table_three[i] = (offset + i * 0x1000) | 0x03;

  // set the first page in the page directory
  page_dir[0] = ((uint32_t) page_table_one) | 3; // set as present
  page_dir[1] = ((uint32_t) page_table_two) | 3; // set as present
  page_dir[2] = ((uint32_t) page_table_three) | 3; // set as present

  load_page_dir(page_dir);
  enable_paging();
}


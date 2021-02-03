global load_page_dir
global enable_paging

# Loads the page directory
# Parameter: address of the page directory (in the stack?)
load_page_dir:
  push ebp
  mov ebp, esp
  mov eax, [esp + 8]
  mov cr3, eax
  mov esp, ebp
  pop ebp
  ret

# Enables paging in register cr0 by setting its 32th bit
enable_paging:
  push ebp
  mov ebp, esp
  mov eax, cr0
  or eax, 0x80000000
  mov cr0, eax
  mov esp, ebp
  pop ebp
  ret


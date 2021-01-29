I will try to document the process of designing an OS here.

# How to make a Bootloader

The first thing that happens when you turn on the computer is to run the BIOS program that exists in
a ROM (read only memory) chip. That program initializes some things and then delegates control to
the bootloader.

The bootloader has the task of preparing the ground for your OS, loading it into memory and jumping
to its initial instructions. In the x86 architecture, the BIOS can identify the bootloader by 2
things:

* it is whatever is contained in the first sector (so-called Master Boot Record or MBR) of the 
  disk used to boot; usually this will be the first 512 bytes in the disk;

* it needs to have a "magic word" as its last 2 bytes: 0x55AA; this is to prevent the BIOS from
  loading garbage as a bootloader.

## Real Mode

When the BIOS handles control to the bootloader, the CPU is in the so-called "Real Mode". This is a
16-bit mode that uses segment registers to enable 20-bit memory addressing, allowing for 1MB of RAM
to be used. This is why you can see in [`boot/boot.asm`](../boot/boot.asm) the assembler directive
`bits 16` -- this tells the assembler to assemble the code using 16-bit mode instructions.

## Loading the Bootloader

Next in our bootloader we can see a `org 0x7c00` directive. This is because the bootloader is loaded
in memory at that address. What this directive does is to use this offset wherever needed, by assuming
this is the starting address of the program (for example for the internal labels of the program).

After the bootloader starts, some of the things we first do is to setup a temporary stack
(using the registers `bp` and `sp`) and to set the video mode (with `int 0x10`). Next we read the
kernel from the disk.

## Reading the Kernel from the Disk

The image that you create for the OS will have to contain the bootloader in the first 512 bytes.
In order to do that you need to add some padding (see the last lines in
[`boot/boot.asm`](../boot/boot.asm)) to the bootloader until it fills 510 bytes, and then the last
2 bytes will be the "magic word" that identifies it as a valid bootloader.

The code from your compiled kernel can come right after those 512 bytes, and therefore will be in
the second sector of the disk. The sectors are numbered starting from 1 (not 0). We use the instruction
`int 0x13` (a BIOS interrupt) to read the disk. We need to specify how many sectors we want to read,
the cylinder (0), the head (0) and the read mode for the interrupt (`ah=0x02`). The data will be
read into `es:bx` (a segmented 20-bit address), and the amount of sectors actually read will be in
register `al`. A read error will set the carry flag. Just to clarify, if we specify the address
`es:bx` as `XXX:0x0000`, this will have the effect of multiplying `XXX` by 16 (= `XXX << 4`).

## The Global Descriptor Table (GDT)

Before we hand control to our kernel, we need to switch from 16-bit mode to 32-bit mode. In 32-bit mode
we can address 4GB of memory, which is enough for our toy OS. However, it is still possible to use
segmentation in 32-bit mode, which can be used for many purposes such as separating the kernel space
from the user space, etc. Actually segmentation is always present, even though in our OS we will make
it useless by creating only 2 segments that completely overlap and take the whole 4GB of memory.

In summary, the CPU will always look at the segment registers (`ds`, ..., `gs`) to resolve memory
addresses. The segment registers will point to entries of the GDT. The content of each entry of the
GDT is basically a 32-bit base address and a 32-bit segment length, plus some flags. Since we set
both segments as covering the whole 4GB of memory (starting from 0), this means that we can use a flat
memory scheme, that is, when we say address 0xABCD, this is the physical address that will be
fetched by the CPU (thanks to the segment registers and our configuration of the GDT).

In order to do this, we must carefully lay this data out in our bootloader and then ask the CPU to
load it with the instruction `lgdt` (load GDT).


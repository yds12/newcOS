Toy OS for learning purposes. Named after 
[Newton da Costa](https://en.wikipedia.org/wiki/Newton_da_Costa).

# Running

You need a Linux machine with `nasm` and `qemu` installed.

Clone the repository and `cd` to the project directory.

Assemble:

    $ nasm boot.asm

Run the binary on `qemu`:

    $ qemu-system-x86_64 -drive format=raw,file=boot

For now you should see a "welcome" message from our OS' bootloader.


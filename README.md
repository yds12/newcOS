Toy OS for learning purposes. Named after 
[Newton da Costa](https://en.wikipedia.org/wiki/Newton_da_Costa).

# Running

You need a Linux machine with `nasm` and `qemu` installed.

Clone the repository and `cd` to the project directory.

Assemble:

    $ nasm -f bin -o boot.bin boot.asm

Run the binary on `qemu`:

    $ qemu-system-x86_64 -drive format=raw,file=boot.bin

For now you should see a "welcome" message from our OS' bootloader.


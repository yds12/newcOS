Toy OS for learning purposes.

We document the process [here](/doc/README.md).

# Running

You need a Linux machine with `nasm`, `qemu` and `make` installed.

Clone the repository and `cd` to the project directory.

Then run:

    $ make

For now you should see a hello message from our kernel, a memory mapping and
the total memory size, plus some other logs.

![NewcOS screenshot](/doc/screenshot.png?raw=true)

# Current State

We have so far:

* Bootloader

* Memory mapping via BIOS

* Interrupt handling

* VGA driver

* Keyboard driver

* Virtual Memory/Paging (very basic so far)

---

Named after
[Newton da Costa](https://en.wikipedia.org/wiki/Newton_da_Costa).


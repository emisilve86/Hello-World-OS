# HELLO-WORLD-OS #

This is a basic BIOS-based bootloader for i386 architectures also providing the entry point for a custom kernel to realize. It provides all instructions required to boot the system in real-mode (16-bit) by exploiting the IVT (interrupt vector table) and the routines offered by the BIOS to load data from disk, and to display strings in VGA text-mode. It also implements all instructions needed to setup the GDT (global description table), and to switch to running in protected mode (32-bit) by allowing the execution of `.code32` instructions compiled against the target i386 architecture, which is an instruction subset of the modern x86 ISA.

## Build ##

To compile `HelloWorldOS` is sufficient to move into the `src/` directory from a terminal and type the following

```c
make
```

The generated image can be tested by launching the following command

```c
make test
```

which loads and executes the binary in an environment that simulates a i386 machine (it requires `qemu-system-i386` be installed).
# Calculator in x86 assembly (v1.4)
## Summary
Error-tolerant, memory-safe, single-digit signed calculator in x86 Assembly (NASM). System-call based I/O, manual memory management, custom macros for input validation, and full runtime error checking. Project served as a crash-course in low-level programming, debugging with GDB, and transitioning from relying on tutorials/GPT to generate all the code to writing good quality (ish) assembly from scratch.

## Introduction
- This is a simple calculator that is written in x86 assembly! My first mini-project to practice assembly.
- Development: 2025-06-08 - 2025-06-29 (Currently paused)
- Version developed: 2025-06-16 - 2025-06-28
- Can handle 1 digit signed numbers (except for division, for which it should be unsigned)

## Packages
To run the app, make sure you have the following packages installed:
1. `nasm` – **Assembler** for compiling x86 assembly source files into object code.
2. `gcc` – **C compiler toolchain** (provides the linker and standard libraries; `ld` is used indirectly or via `binutils`).
3. `make` – **Build automation tool** used to run the `Makefile` targets like `make`, `make run`, etc.
4. `gdb` – **GNU Debugger** (optional) – useful for stepping through and debugging your assembly code.

For Debian/ Ubuntu-based systems:
```
sudo apt update
sudo apt install nasm gcc make gdb
``` 

For Arch Linux:
```
sudo pacman -S nasm base-devel gdb
```

## Running the app
This app should be ran on x86 architecture. It will not run on ARM machines (e.g., Silicon Macs). To run the app simply:
1. Type `make` to assemble the source code in the terminal (make sure you are in the correct directory)
2. Type `make run` to run the program
3. To debug the program using GDB use `make debug`

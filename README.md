# Calculator v1
## Introduction
- This is a simple calculator that is written in x86 assembly! My first mini-project to practice assembly.
- Developed 2025-06-08 - 2025-06-13
- It can only handle single digit imput and output
    - e.g., 4+5 will work
    - e.g., 5+6 will not work since the output is 2 digits

## Packages
- To run the app make sure you have the following packages:
    1. 

- For Debian/ Ubuntu-based systems:
```
sudo apt update
sudo apt install nasm gcc make gdb
``` 

- For Arch Linux:
```
sudo pacman -S nasm base-devel gdb
```

## Running the app
- This app should be ran on x86 architecture. It will not run on ARM machines (e.g., Silicon Macs)
- To run the app simply:
    1. Type `make` to assemble the source code in the terminal (make sure that you are in the correct directory)
    2. Type `make run` to run the program
    3. To debug the program using GDB use `make debug`

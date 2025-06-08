.PHONY: all run clean debug

all: main

main: ./src/main.asm
	nasm -f elf32 -g -F dwarf ./src/main.asm -o ./build/main.o
	ld -m elf_i386 -o ./build/main ./build/main.o

run: main
	./build/main

debug: main
	gdb ./build/main

clean:
	rm ./build/*

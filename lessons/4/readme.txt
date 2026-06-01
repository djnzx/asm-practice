compile:
nasm -f elf32 int2string-app.asm -o int2string-app.o

link:
ld -m elf_i386 int2string-app.o -o int2string-app

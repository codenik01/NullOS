all:
	nasm -f bin boot.asm -o boot.bin

	nasm -f elf32 kernel_entry.asm -o kernel_entry.o

	i686-elf-gcc -ffreestanding -m32 -c kernel.c -o kernel.o

	i686-elf-ld -o kernel.bin -T linker.ld kernel_entry.o kernel.o --oformat binary

	cat boot.bin kernel.bin > nullos.img

run:
	qemu-system-x86_64 \
	-drive if=floppy,format=raw,file=nullos.img \
	-display cocoa,zoom-to-fit=on \
	-full-screen

clean:
	rm -f *.bin *.o *.img

CCompiller = cc
CFlags = -c -I ../Include/
CadFlags = -nostdlib -nostartfiles

Linker = ld
LFlags = -e Initialize -T link.ld -s

all: CompileKernel LinkKernel Objcopy Run Clear

CompileKernel:
	$(CCompiller) $(CFlags) $(CadFlags) Kernel.c Init.c ./HardwareLevel/HAL.c ./HardwareLevel/GDT.c
LinkKernel:
	$(Linker) $(LFlags) Init.o HAL.o GDT.o Kernel.o -o Kernel.bin
Objcopy:
	objcopy -R .eh_frame -O binary Kernel.bin
Run:
	mv Kernel.bin ../Test
Clear:
	rm *.o
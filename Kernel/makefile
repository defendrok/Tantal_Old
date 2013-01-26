CCompiller = cc
CFlags = -c -I ../Include/
CadFlags = -nostdlib -nostartfiles

Linker = ld
LFlags = -e Initialize -T link.ld -s

all: CompileKernel LinkKernel Objcopy Run

CompileKernel:
	$(CCompiller) $(CFlags) $(CadFlags) Kernel.c Init.c ./HardwareLevel/HAL.c
LinkKernel:
	$(Linker) $(LFlags) *.o -o Kernel.bin
Objcopy:
	objcopy -R .eh_frame -O binary Kernel.bin
Run:
	mv Kernel.bin ../Test
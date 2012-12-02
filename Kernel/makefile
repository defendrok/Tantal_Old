CCompiller = cc
CFlags = -c
CadFlags = -Wall -nostdlib -nostartfiles

Linker = ld
LFlags = -e Initialize -T link.ld -s

all: CompileKernel LinkKernel Objcopy Run

CompileKernel:
	$(CCompiller) $(CFlags) $(CadFlags) Kernel.c
LinkKernel:
	$(Linker) $(LFlags) *.o -o Kernel.bin
Objcopy:
	objcopy -R .eh_frame -O binary Kernel.bin
Run:
	mv Kernel.bin ../Test
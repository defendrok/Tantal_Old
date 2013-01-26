disk = disk1.img

all: CopyStage2 CopyKernel

CopyStage2:
	mcopy -i $(disk) Stage2.bin ::/
CopyKernel:
	mcopy -i $(disk) Kernel.bin ::/
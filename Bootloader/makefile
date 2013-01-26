Assembler = nasm
AFlags = -f bin -o

all: Stage1 Stage2

#Compilling and moving to the test folder
Stage1:
	$(Assembler) Stage1.asm $(AFlags) Stage1.bin
	mv Stage1.bin ../Test
Stage2:
	$(Assembler) Stage2.asm $(AFlags) Stage2.bin -I/media/Storage/Work/Code/OS/Tantal/Bootloader/
	mv Stage2.bin ../Test
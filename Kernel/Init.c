extern void Main();
//
extern void Initialize()
{
	//don't need because of -masm=intel
	//seems that it is still needed 
	asm volatile (".intel_syntax noprefix");
	asm volatile
	(
		"cli\n"
        "mov ax, 0x10\n"
        "mov ds, ax\n"
        "mov es, ax\n"
        "mov fs, ax\n"
        "mov gs, ax\n"
	);
	asm volatile (".att_syntax noprefix");
	Main();
}

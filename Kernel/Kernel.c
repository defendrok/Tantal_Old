//Include section
# include "../Include/Var.h"
# include "../Include/Video.c"

//
extern void Main(void);
//Code section
void Main(void)
{
	//Displaing entrance text
	ClearScreen(0x48);
	SetColor(0x48); PrintString("Remastered kernel");
	PrintCharacter('l');
	
	//Infinite loop
	for(;;);
}
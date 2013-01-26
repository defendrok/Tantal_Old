//Include section
# include "Var.h"
# include "Video.c"
# include "./HardwareLevel/HAL.h"

//Code section
void Main(void)
{
	//Displaing entrance text
	ClearScreen(0x20);
	SetColor(0x40); PrintString("Setting GDT... \n");
	
	HardwareInitialize();
	PrintString("Maybe GDT is set =)");
	
	//Infinite loop
	for(;;);
}
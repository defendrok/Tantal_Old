///Include and initialization section
# include "Var.h"

UChar SetColor(const UChar);
UInt StringLenght(const Char*);
void ClearScreen(const UChar);
void PrintCharacter(Char);
void PrintString(Char*);
void SetCursor(UShort, UShort);
//--------------------------------------------------------------------
///Data section
UShort *VideoMemory = (UShort *)0xb8000; //unsigned char pointer to the start of VGA video memory

//Cursor position
UChar PositionX = 0;
UChar PositionY = 0;

//Current color
UChar Color = 0;
//--------------------------------------------------------------------
///Code section
// Clearing the screen
// Следует указывать цвет целиком, иначе "понесеться"
void ClearScreen(const UChar color)
{
	UShort *VideoMemory = (UShort *)0xb8000;
	Int i;
	for(i = 0; i < 25*80; ++i)
		VideoMemory[i] = 32 | (color << 8);
	SetCursor(0, 0);
}
//Printing a string
void PrintString(Char* string)
{
	if(!string)
		return;
	UInt i;
	for(i = 0; i < StringLenght(string); i++)
		PrintCharacter(string[i]);
}
//Printing One character
void PrintCharacter(Char CharToPrint)
{
	UShort Attribute = (Color << 8);

	//Printable Chars
	if (CharToPrint >= ' ')
	{
		UShort *Location = VideoMemory + (PositionY * 80 + PositionX);
		*Location = CharToPrint | Attribute;
		PositionX++;
	}
	//Backspace
	else if (CharToPrint == 0x08 && PositionX)
		PositionX--;
	//Tab(ulation)
	else if (CharToPrint == 0x09)
		PositionX += 4; //another wariant is //(cursor_x+8) & ~(8-1) 
						//have to deside which is better
	//Carriage return
	else if (CharToPrint == '\r')
		PositionX = 0;
	//New line
	else if (CharToPrint == '\n')
	{
		PositionX = 0;
		PositionY++;
	}

	//Reached the end of the line?
	if (PositionX >= 80)
	{
		PositionX = 0;
		PositionY++;
	}
}
//Setting color of the printing text
UChar SetColor(const UChar color)
{
	UChar DColor = Color;
	Color = color;
	return DColor;
}
//Setting position of the cursor
void SetCursor(UShort x, UShort y)
{
	if(x<=80)
		PositionX = x;
	if(y<=25)
		PositionY = y;
}
//Getting String Lenght
UInt StringLenght(const Char* string)
{
	UInt Lenght = 0;
	while(string[Lenght++]);
		return Lenght;
}
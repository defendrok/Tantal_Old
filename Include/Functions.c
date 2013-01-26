#include "Var.h"

void SetMemory(void*, Char, UInt);

void SetMemory(void* Destination, Char Value, UInt Count)
{
	UChar *Temp = (UChar *)Destination;
	for(; Count != 0; Count--)
		Temp[Count] = Value;
}
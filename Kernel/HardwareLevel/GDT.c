/*	GDT
Bits 56-63: Bits 24-32 of the base address
Bit 55: Granularity
	0: None
	1: Limit gets multiplied by 4K
Bit 54: Segment type
	0: 16 bit
	1: 32 bit
Bit 53: Reserved-Should be zero
Bits 52: Reserved for OS use
Bits 48-51: Bits 16-19 of the segment limit
Bit 47 Segment is in memory (Used with Virtual Memory)
Bits 45-46: Descriptor Privilege Level
	0: (Ring 0) Highest
	3: (Ring 3) Lowest
Bit 44: Descriptor Bit
	0: System Descriptor
	1: Code or Data Descriptor
Bits 41-43: Descriptor Type
Bit 43: Executable segment
	0: Data Segment
	1: Code Segment
Bit 42: Expansion direction (Data segments), conforming (Code Segments)
Bit 41: Readable and Writable
	0: Read only (Data Segments); Execute only (Code Segments)
	1: Read and write (Data Segments); Read and Execute (Code Segments)
Bit 40: Access bit (Used with Virtual Memory)
Bits 16-39: Bits 0-23 of the Base Address
Bits 0-15: Bits 0-15 of the Segment Limit
*/
#include "GDT.h"

#include "Var.h"
#include "Functions.c"

/* GDT Descriptor
 * a single record in this table determines a block
 * of memory with a certain priveledge level and size
 */
struct GDTDescriptor
{
	UShort Limit;
	UShort BaseLow;
	UChar BaseMiddle;
	UChar Flags;
	UChar Grand;
	UChar BaseHeight;
}__attribute__((packed));
/*GDTR register
 * A structure that represents a register which stores
 * information about a location of Global Descriptor Table
 */
struct GDTR
{
	UShort Limit;
	UInt Base;
}__attribute__((packed));
//Data structures represent GDT Table and data to be stored in gdtr
static struct GDTDescriptor GDTTable[MaxDescriptors];
static struct GDTR GDTRegisterData;

static void InstallGDT(void)
{
	asm volatile (".intel_syntax noprefix");
	asm volatile ("lgdt [GDTRegisterData]");
	asm volatile (".att_syntax noprefix");
}

void GDTSetDescriptor(UInt Index, ULong Base, ULong Limit, UChar Access, UChar Granularity)
{
	if(MaxDescriptors < Index)
		return;
	
	SetMemory((void*)&GDTTable[Index], 0, sizeof(GDTDescriptor));
	
	GDTTable[Index].BaseLow = Base & 0xffff;
	GDTTable[Index].BaseMiddle = (Base >> 16) & 0xff;
	GDTTable[Index].BaseHeight = (Base >> 24) & 0xff;
	GDTTable[Index].Limit = Limit & 0xffff;
	GDTTable[Index].Flags = Access;
	GDTTable[Index].Grand = (Limit >> 16) & 0x0f;
	GDTTable[Index].Grand |= Granularity & 0xf0;
}

Int InitializeGDT(void)
{
	//Setting GDTR
	GDTRegisterData.Base = (UInt)&GDTTable[0];
	GDTRegisterData.Limit = (sizeof(GDTDescriptor) * MaxDescriptors) - 1;
	
	GDTSetDescriptor(0, 0, 0, 0, 0);	//Setting Null Descriptor
	GDTSetDescriptor(1, 0, 0xffffffff, DESC_READWRITE | DESC_EXEC_CODE | DESC_CODEDATA | DESC_MEMORY, GRAND_4K | GRAND_32BIT | GRAND_LIMITHI_MASK);	//Setting Code Descriptor
	GDTSetDescriptor(2, 0, 0xffffffff, DESC_READWRITE | DESC_CODEDATA | DESC_MEMORY, GRAND_4K | GRAND_32BIT | GRAND_LIMITHI_MASK);	//Setting Data Descriptor
	
	InstallGDT();
	return 0;	//Leaving the functuon
}
#ifndef GDT_H
#define GDT_H

#include "Var.h"

void GDTSetDescriptor(UInt, ULong, ULong, UChar, UChar);
Int InitializeGDT(void);

#define MaxDescriptors 3

/***	 gdt descriptor access bit flags.	***/
//! set access bit
#define DESC_ACCESS			0x0001			//00000001
//! descriptor is readable and writable. default: read only
#define DESC_READWRITE			0x0002			//00000010
//! set expansion direction bit
#define DESC_EXPANSION			0x0004			//00000100
//! executable code segment. Default: data segment
#define DESC_EXEC_CODE			0x0008			//00001000
//! set code or data descriptor. defult: system defined descriptor
#define DESC_CODEDATA			0x0010			//00010000
//! set dpl bits
#define DESC_DPL			0x0060			//01100000
//! set "in memory" bit
#define DESC_MEMORY			0x0080			//10000000

/***	gdt descriptor grandularity bit flags	***/
//! masks out limitHi (High 4 bits of limit)
#define GRAND_LIMITHI_MASK		0x0f			//00001111
//! set os defined bit
#define GRAND_OS			0x10			//00010000
//! set if 32bit. default: 16 bit
#define GRAND_32BIT			0x40			//01000000
//! 4k grandularity. default: none
#define GRAND_4K			0x80			//10000000

#endif

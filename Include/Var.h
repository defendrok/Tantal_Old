#ifndef VAR_H
#define VAR_H

//	Standart C Null declaration
# define NULL (void*)0

// Value tupe defenitions
// --- chars --- //
typedef unsigned char UChar;
typedef char Char;
// --- short int --- //
typedef unsigned short UShort;
typedef short  Short;
// --- int --- //
typedef unsigned int UInt;
typedef int Int;
// --- long int --- //
typedef long  Long;         	                            	// 32 bits length
typedef unsigned long  ULong;                        		// unsigned 32 bits length
// --- long long int --- //
typedef unsigned long long  UBig; 	                    	// 64-bit length unsigned 
typedef long long Big;                               	        // 64-bit length
// --- decimals --- //
typedef float	Float;
typedef double Double;
typedef long double Triple;	                              	// 80-bit length. Actual properties unspecified.

#endif
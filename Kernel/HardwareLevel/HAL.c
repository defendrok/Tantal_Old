/* Goal of this module
 *All the hardware devices should be
 * initialized here, in order to seperate
 * software and hardware representaion in the code
*/
#include "Var.h"
#include "GDT.h"

#include "HAL.h"

//! Initialize and shut down HAL
Int HardwareInitialize(void)
{
	InitializeGDT();
	return 0;
}

Int HardwareShutdown(void)
{
	return 0;
}


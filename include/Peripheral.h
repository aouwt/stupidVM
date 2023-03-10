#ifndef PERIPHERAL_H
	#define PERIPHERAL_H
	
	#include "stupidVM.h"
	
	typedef struct _PeripheralBus {
		bool RW;
		U8 addr;
		Word word;
	} PeripheralBus;

	
	typedef void (* PeripheralFunc_NoArg) (void *);
	typedef void (* PeripheralFunc_IO) (void *, PeripheralBus *);
	
	typedef struct _PeripheralInfo {
		PeripheralFunc_NoArg Constructor, Destructor;
		PeripheralFunc_NoArg Int;
		PeripheralFunc_IO IO;
		char Name [5];
		size_t Size;
		U8 Slots;
	} PeripheralInfo;
#endif

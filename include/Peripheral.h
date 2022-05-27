#ifndef PERIPHERAL_H
	#define PERIPHERAL_H
	
	#include "stupidVM.h"
	
	typedef struct _PeripheralBus {
		bool RW;
		U8 addr;
		Word word;
	} PeripheralBus;


	typedef struct _PeripheralInfo {
		void (* Constructor) (void *);
		void (* Destructor) (void *);
		void (* IO) (void *, PeripheralBus *);
		void (* Int) (void *);
		char Name [16];
		size_t Size;
	} PeripheralInfo;
#endif

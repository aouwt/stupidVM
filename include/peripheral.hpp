#ifndef PERIPHERAL_HPP
	#define PERIPHERAL_HPP
	
	#include <stdint.h>
	
	#include "stupidVM.hpp"
	
	struct PeripheralBus {
		bool RW;
		U8 addr;
		Word word;
	};
	
	typedef 
	struct Peripheral {
		PeripheralBus Bus;
		void (* Constructor) (void);
		void (* Destructor) (void);
		void (* IO) (void);
		void (* OnInt) (U8 Int);
	};
#endif

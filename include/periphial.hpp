#ifndef PERIPHERAL_HPP
	#define PERIPHERAL_HPP
	
	#include <stdint.h>
	
	#include "stupidVM.hpp"
	
	struct PeripheralBus {
		bool RW;
		U8 addr;
		Word word;
	};
	
	typedef void (* PeripheralFunc) (struct PeripheralBus *);
#endif

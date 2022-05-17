#ifndef PERIPHERAL_HPP
	#define PERIPHERAL_HPP
	
	#include <stdint.h>
	
	#include "stupidVM.hpp"
	
	class Peripheral {
		struct Bus {
			bool RW;
			uint_least8_t addr;
			Word word;
		};
		
		bool (* Constructor) (Peripheral *_this) = NULL;
		void (* BusAction) (Peripheral *_this) = NULL;
		void (* Destructor) (Peripheral *_this) = NULL;
	};
#endif

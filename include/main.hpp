#ifndef MAIN_HPP
	#define MAIN_HPP
	
	#include "SMP100.hpp"
	#include "Peripherals.hpp"
	#include "stupidVM.h"

	extern SMP100 *CPU;
	extern Peripherals *Perip;

	namespace Memories {
		extern uint8_t ASpace [0xFFFF];
		extern uint8_t *Banks [0xFF];
		extern U8 CurBank;
	};
#endif

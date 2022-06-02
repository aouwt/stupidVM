#ifndef MAIN_HPP
	#define MAIN_HPP
	
	#include "SMP100.hpp"
	#include "Peripherals.hpp"
	#include "stupidVM.h"

	extern SMP100 *CPU;
	extern Peripherals *Perip;

	namespace Memories {
		extern Word ASpace [0xFFFF];
		extern Word *Banks [0xFF];
		extern U8 CurBank;
	};
#endif

#ifndef SMP100C_HPP
	#define SMP100C_HPP
	
	#include <SDL_thread.h>
	#include <SDL_mutex.h>
	
	#include "stupidVM.h"
	#include "stupidVM_Supp.hpp"
	#include "Peripheral.h"
	#include "SMP100.hpp"
	
	struct SMP100c {
		SMP100 *SMP;
		SDL_Thread *Thread;
		SDL_mutex *Halt;
		U16 RAMMask;
		U8 *RAM;
		Timer *timer;
		bool CleanupSig = false;
		bool IsHalted;
	};
	
	extern const PeripheralInfo SMP100c;
#endif

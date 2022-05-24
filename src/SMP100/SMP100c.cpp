#include <SDL.h>
#include <SDL_thread.h>
#include <SDL_mutex.h>
#include "stupidVM.hpp"
#include "peripheral.hpp"
#include "SMP100.hpp"
#include "SMP100c.hpp"


static int threadfunc (void *__this) {
	SMP100c *_this = (SMP100c *) __this;
	Pair *bus = &_this -> SMP -> Bus;
	
	SDL_LockMutex (_this -> Halt); // Halt provides double purpose -- as a lock for CleanupSig, and as a halt thing
	while (_this -> CleanupSig == false) {
		SDL_UnlockMutex (_this -> Halt);
		
		_this -> timer -> Wait ();
		
		SDL_LockMutex (_this -> Halt);
		
		_this -> SMP -> Cycle ();
		
		if (bus -> RW == RW_READ)
			bus -> word = _this -> RAM [bus -> addr & _this -> RAMMask];
		else
			_this -> RAM [bus -> addr & _this -> RAMMask] = bus -> word;
	}
	
	return 0;
}

SMP100c::SMP100c (U16 ClockRate, U16 RAM) {
	SMP = new SMP100 (0x0000, 0x0100);
	timer = new Timer (ClockRate);
	Halt = SDL_CreateMutex ();
	
	Thread = SDL_CreateThread (threadfunc, "SMP100c cycle task", (void *) this);
}

SMP100c::~SMP100c (void) {
	SDL_LockMutex (Halt);
	CleanupSig = true;
	SDL_UnlockMutex (Halt);
	
	SDL_WaitThread (Thread, NULL);
	
	SDL_DestroyMutex (Halt);
	delete timer;
	delete SMP;
}

void SMP100c::PeripheralFunc (PeripheralBus *bus) {
	static bool IsHalted;
	
	switch (bus -> addr & 0b11) {
		case 0:
			if (bus -> RW == RW_READ) {
				if (IsHalted)
					bus -> word = 1;
				else
					bus -> word = 0;
			} else {
				IsHalted = bus -> word;
				if (IsHalted)
					SDL_LockMutex (Halt);
				else
					SDL_UnlockMutex (Halt);
			}
			break;
		
		case 1:
			if (bus -> RW == RW_READ)
				bus -> word = SMP -> Bus.addr & 0x00FF;
			else
				SMP -> Bus.addr = (SMP -> Bus.addr & 0xFF00) | bus -> word;
			break;
			
		case 2:
			if (bus -> RW == RW_READ)
				bus -> word = (SMP -> Bus.addr & 0xFF00) >> 8;
			else
				SMP -> Bus.addr = (SMP -> Bus.addr & 0x00FF) | (bus -> word << 8);
			break;
		
		case 3:
			SMP -> Bus.RW = bus -> RW;
			
			if (bus -> RW == RW_READ)
				bus -> word = RAM [SMP -> Bus.addr];
			else
				RAM [SMP -> Bus.addr] = bus -> word;
			break;
	}
}

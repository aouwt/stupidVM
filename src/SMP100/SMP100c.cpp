#include <SDL.h>
#include <SDL_thread.h>
#include <SDL_mutex.h>
#include "stupidVM.hpp"
#include "Peripheral.hpp"
#include "SMP100.hpp"
#include "SMP100c.hpp"

static int thread (void *__this) {
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


static void construct (void *__this) {
	SMP100c *_this = (SMP100c *) __this;
	
	_this -> SMP = new SMP100 (0x0000, 0x0100);
	_this -> timer = new Timer (8000);
	_this -> Halt = SDL_CreateMutex ();
	
	_this -> Thread = SDL_CreateThread (thread, "SMP100c cycle task", __this);
}


static void destruct (void *__this) {
	SMP100c *_this = (SMP100c *) __this;
	
	SDL_LockMutex (_this -> Halt);
	_this -> CleanupSig = true;
	SDL_UnlockMutex (_this -> Halt);
	
	SDL_WaitThread (_this -> Thread, NULL);
	
	SDL_DestroyMutex (_this -> Halt);
	delete _this -> timer;
	delete _this -> SMP;
}

static void pf_io (void *__this, Peripheral::PeripheralBus *bus) {
	SMP100c *_this = (SMP100c *) __this;	
	
	switch (bus -> addr & 0b11) {
		case 0:
			if (bus -> RW == RW_READ) {
				if (_this -> IsHalted)
					bus -> word = 1;
				else
					bus -> word = 0;
			} else {
				_this -> IsHalted = bus -> word;
				if (_this -> IsHalted)
					SDL_LockMutex (_this -> Halt);
				else
					SDL_UnlockMutex (_this -> Halt);
			}
			break;
		
		case 1:
			if (bus -> RW == RW_READ)
				bus -> word = _this -> SMP -> Bus.addr & 0x00FF;
			else
				_this -> SMP -> Bus.addr = (_this -> SMP -> Bus.addr & 0xFF00) | bus -> word;
			break;
			
		case 2:
			if (bus -> RW == RW_READ)
				bus -> word = (_this -> SMP -> Bus.addr & 0xFF00) >> 8;
			else
				_this -> SMP -> Bus.addr = (_this -> SMP -> Bus.addr & 0x00FF) | (bus -> word << 8);
			break;
		
		case 3:
			_this -> SMP -> Bus.RW = bus -> RW;
			
			if (bus -> RW == RW_READ)
				bus -> word = _this -> RAM [_this -> SMP -> Bus.addr];
			else
				_this -> RAM [_this -> SMP -> Bus.addr] = bus -> word;
			break;
	}
}


const Peripheral::PeripheralInfo SMP100c::PeripheralInfo = {
	.Constructor = &construct,
	.Destructor = &destruct,
	.IO = &pf_io,
	.Int = NULL,
	.Name = "SMP100c"
};


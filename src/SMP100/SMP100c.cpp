#include <SDL.h>
#include <SDL_thread.h>
#include <SDL_mutex.h>
#include "stupidVM.h"
#include "Peripheral.h"
#include "SMP100.hpp"
#include "SMP100c.hpp"

static int thread (void *_this) {
	struct SMP100c *_ = (struct SMP100c *) _this;
	Pair *bus = &_->SMP -> Bus;
	
	SDL_LockMutex (_->Halt); // Halt provides double purpose -- as a lock for CleanupSig, and as a halt thing
	while (_->CleanupSig == false) {
		SDL_UnlockMutex (_->Halt);
		
		_->timer -> Wait ();
		
		SDL_LockMutex (_->Halt);
		
		_->SMP -> Cycle ();
		
		if (bus -> RW == RW_READ)
			bus -> word = _->RAM [bus -> addr & _->RAMMask];
		else
			_->RAM [bus -> addr & _->RAMMask] = bus -> word;
	}
	
	return 0;
}


static void construct (void *_this) {
	struct SMP100c *_ = (struct SMP100c *) _this;
	
	_->SMP = new SMP100 (0x0000, 0x0100);
	_->timer = new Timer (8000);
	_->Halt = SDL_CreateMutex ();
	
	_->Thread = SDL_CreateThread (thread, "SMP100c cycle task", _this);
}


static void destruct (void *_this) {
	struct SMP100c *_ = (struct SMP100c *) _this;
	
	SDL_LockMutex (_->Halt);
	_->CleanupSig = true;
	SDL_UnlockMutex (_->Halt);
	
	SDL_WaitThread (_->Thread, NULL);
	
	SDL_DestroyMutex (_->Halt);
	delete _->timer;
	delete _->SMP;
}

static void pf_io (void *_this, PeripheralBus *bus) {
	struct SMP100c *_ = (struct SMP100c *) _this;	
	
	switch (bus -> addr & 0b11) {
		case 0:
			if (bus -> RW == RW_READ) {
				if (_->IsHalted)
					bus -> word = 1;
				else
					bus -> word = 0;
			} else {
				_->IsHalted = bus -> word;
				if (_->IsHalted)
					SDL_LockMutex (_->Halt);
				else
					SDL_UnlockMutex (_->Halt);
			}
			break;
		
		case 1:
			if (bus -> RW == RW_READ)
				bus -> word = _->SMP -> Bus.addr & 0x00FF;
			else
				_->SMP -> Bus.addr = (_->SMP -> Bus.addr & 0xFF00) | bus -> word;
			break;
			
		case 2:
			if (bus -> RW == RW_READ)
				bus -> word = (_->SMP -> Bus.addr & 0xFF00) >> 8;
			else
				_->SMP -> Bus.addr = (_->SMP -> Bus.addr & 0x00FF) | (bus -> word << 8);
			break;
		
		case 3:
			_->SMP -> Bus.RW = bus -> RW;
			
			if (bus -> RW == RW_READ)
				bus -> word = _->RAM [_->SMP -> Bus.addr];
			else
				_->RAM [_->SMP -> Bus.addr] = bus -> word;
			break;
	}
}


const PeripheralInfo SMP100c = {
	.Constructor = &construct,
	.Destructor = &destruct,
	.IO = &pf_io,
	.Int = NULL,
	.Name = "SMP100c",
	.Size = sizeof (struct SMP100c)
};


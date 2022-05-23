#include <SDL.h>
#include <SDL_thread.h>
#include "stupidVM.hpp"
#include "peripheral.hpp"
#include "SMP100.hpp"
#include "SMP100c.hpp"


static int threadfunc (void *__this) {
	SMP100c *_this = (SMP100c *) __this;
	Pair *bus = &_this -> SMP -> Bus;
	
	while (true) {
		_this -> SMP -> Cycle ();
		
		if (bus -> RW == RW_READ)
			bus -> word = _this -> RAM [bus -> addr & _this -> RAMMask];
		else
			_this -> RAM [bus -> addr & _this -> RAMMask] = bus -> word;
	}
}

SMP100c::SMP100c (U16 ClockRate, U16 RAM) {
	SMP = new SMP100 (0x0000, 0x0100);
}

SMP100c::~SMP100c (void) {
	delete SMP;
}

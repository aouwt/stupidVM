#include <SDL.h>
#include "stupidVM_SDL.hpp"

Timer::Timer (float Hz) {
	Interval = 1000.0 / Hz;
}

void Timer::Wait (void) {
	static U32 target = 0;
	U32 now = SDL_GetTicks ();
	
	if (target > now)
		SDL_Delay (target - now);
	
	target = now + Interval;
}

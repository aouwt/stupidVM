#include <sys/time.h>
#include <unistd.h>
#include "stupidVM_SDL.hpp"

Timer::Timer (float Hz) {
	Interval = (1000000.0 / Hz);
}

void Timer::Wait (void) {
	struct timeval tv;
	gettimeofday (&tv, NULL);
	
	U64 now = tv.tv_sec * 1000000LU + tv.tv_usec;
	
	if (Target > now)
		usleep (Target - now);
	
	Target = now + Interval;
}

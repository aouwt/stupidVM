#ifndef STUPIDVM_SDL_HPP
	#define STUPIDVM_SDL_HPP
	
	#include <unistd.h>
	
	#include "stupidVM.h"
	
	class Timer {
		public:
			Timer (float Hz);
			
			void Wait (void);
			bool IsLate (void);
			
		private:
			U64 Interval, Target = 0;
	};
#endif

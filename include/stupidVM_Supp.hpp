#ifndef STUPIDVM_SDL_HPP
	#define STUPIDVM_SDL_HPP
	
	#include <unistd.h>
	
	#include "stupidVM.hpp"
	
	class Timer {
		public:
			Timer (float Hz);
			
			void Wait (void);
			bool IsLate (void);
			
		private:
			U64 Interval, Target = 0;
	};
#endif

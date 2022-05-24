#ifndef STUPIDVM_SDL_HPP
	#define STUPIDVM_SDL_HPP
	
	#include "stupidVM.hpp"
	
	class Timer {
		public:
			Timer (float Hz);
			
			void Wait (void);
			bool IsLate (void);
			
		private:
			U16 Interval;
	};
#endif

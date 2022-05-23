#ifndef STUPIDVM_SDL_HPP
	#define STUPIDVM_SDL_HPP
	
	#include "stupidVM.hpp"
	
	class Timer {
		public:
			Timer (U16 Hz);
			~Timer (void);
			
			void Wait (void);
			
		private:
			U16 Interval;
			
			U32 LastTime = 0;
	};
#endif

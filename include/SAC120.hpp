#ifndef SAC110_HPP
	#define SAC110_HPP
	
	#include <SDL.h>
	#include <SDL_audio.h>
	
	#include "stupidVM.hpp"
	#include "peripheral.hpp"
	
	class SAC120 {
		public:
			struct Sample {
				U16 Len = 256;
				U8 Dat [256];
			};
			
			struct Channel {
				U16 SampTime = 0;
				U16 ToNext = 0;
				float Amp = 0;
				U16 CurSamp = 0;
				struct Sample *Samp = NULL;
			};
			struct Channel Chs [4];
			
			SAC120 (SDL_AudioSpec *Spec);
			SAC120 (void) { SAC120 (NULL); }
			~SAC120 (void);
			
			SDL_AudioSpec AudSpec;
			void PeripheralFunc (PeripheralBus *Bus);
	};
#endif

#ifndef SAC110_HPP
	#define SAC110_HPP
	
	#include <SDL.h>
	#include <SDL_audio.h>
	
	#include "stupidVM.hpp"
	#include "periphial.hpp"
	
	class SAC110 {
		public:
			struct Sample {
				U16 Len = 256;
				U8 Dat [256];
			};
			
			static const struct Sample Waveforms [4];
			
			struct Channel {
				U16 SampTime = 0;
				U16 ToNext = 0;
				float Amp = 0;
				U16 CurSamp = 0;
				struct Sample *Samp = NULL;
			};
			struct Channel Chs [4];
			
			SAC110 (SDL_AudioSpec *Spec);
			
			SDL_AudioSpec AudSpec;
			void PeripheralFunc (PeripheralBus *Bus);
	};
#endif

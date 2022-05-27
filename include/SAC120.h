#ifndef SAC120_H
	#define SAC120_H
	
	#include <SDL.h>
	#include <SDL_audio.h>
	
	#include "stupidVM.h"
	#include "Peripheral.h"
	
	struct SAC120 {
			struct Sample {
				U16 Len;
				U8 Dat [256];
			};
			
			struct Channel {
				U16 SampTime;
				U16 ToNext;
				float Amp;
				U16 CurSamp;
				struct Sample *Samp;
			};
			struct Channel Chs [4];
			
			Word Regs [16];
			struct Sample Waveforms [256];
			
			SDL_AudioSpec AudSpec;
	};
	
	extern const PeripheralInfo SAC120;
#endif

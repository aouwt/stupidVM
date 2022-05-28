#ifndef SAC120_INTERNAL_H
	#define SAC120_INTERNAL_H
	
	#include <SDL.h>
	#include <SDL_audio.h>
	
	#include "SAC120.h"
	
	typedef uint8_t SAC120_Sample;
	struct SAC120 {
		struct Channel {
			U16 SampTime;
			U16 ToNext;
			float Amp;
			U16 CurSamp;
			SAC120_Sample *Samp;
		};
		struct Channel Chs [4];
		
		Word Regs [16];
		SAC120_Sample Waveforms [64] [256];
		
		SDL_AudioSpec AudSpec;
	};
#endif

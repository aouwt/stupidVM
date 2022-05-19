#include <SDL.h>
#include <SDL_audio.h>

#include "stupidVM.hpp"
#include "periphial.hpp"
#include "SAC110.hpp"

static SDL_AudioSpec DefaultAS = {
	
};

void callback (void *udat, uint8_t *stream, int len) {
	SAC110 *_this = (SAC110 *) udat;
	for (int i = 0; i != len; i ++) {
	
		stream [i] = 0;
		
		for (U8 ch = 0; ch != 3; ch ++) {
			
			if (-- _this -> Chs [ch].ToNext == 0) {
				if (++ _this -> Chs [ch].CurSamp >= _this -> Chs [ch].Samp -> Len)
					_this -> Chs [ch].CurSamp = 0;
				_this -> Chs [ch].ToNext = _this -> Chs [ch].SampTime;
			}
			
			stream [i] += (_this -> Chs [ch].Samp -> Dat [_this -> Chs [ch].CurSamp]) * _this -> Chs [ch].Amp;
		}
		
	}
}

void SAC110::PeripheralFunc (PeripheralBus *bus) {
	if (bus -> RW == RW_WRITE) {
		switch (bus -> addr) {
			case 0x0:
			
		}
	}
}

SAC110::SAC110 (SDL_AudioSpec *Spec) {
	SDL_Init (SDL_INIT_AUDIO);
	if (Spec == NULL)
		Spec = &DefaultAS;
	
	SDL_AudioSpec request = *Spec;
	
	request.callback = &callback;
	request.format = AUDIO_U8; // atm, we only support 8 bit audio....
	request.userdata = (void *) this;
	
	SDL_OpenAudio (&request, &AudSpec);
}

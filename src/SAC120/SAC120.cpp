#include <SDL.h>
#include <SDL_audio.h>

#include "stupidVM.hpp"
#include "periphial.hpp"
#include "SAC120.hpp"

void callback (void *udat, uint8_t *stream, int len);

static SDL_AudioSpec DefaultAS = {
	.freq = 44100,
	.format = AUDIO_U8,
	.samples = 512,
	.callback = &callback,
	.userdata = NULL
};

static struct SAC120::Sample Waveforms [256];



void callback (void *udat, uint8_t *stream, int len) {
	SAC120 *_this = (SAC120 *) udat;
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

void SAC120::PeripheralFunc (PeripheralBus *bus) {
	static Word Regs [16];
	
	if (bus -> RW == RW_WRITE) {
		Regs [bus -> addr] = bus -> word;
		
		if ((bus -> addr & 0x03) == 3) { // write to volume byte to push change
			U8 ch = (bus -> addr & 0xC) >> 2; // get top 2 bits
			
			Chs [ch].Samp = &Waveforms [Regs [ch + 2]];
			Chs [ch].Amp = Regs [ch + 3] / 256.0;
			Chs [ch].SampTime =
				(AudSpec.freq / // convert to samples
					(Regs [ch + 0] & (Regs [ch + 1] << 8)) // get frequency
				) / Chs [ch].Samp -> Len // convert to samptime
			;
		}
	} else
		bus -> word = Regs [bus -> addr];
}

SAC120::SAC120 (SDL_AudioSpec *Spec) {
	SDL_Init (SDL_INIT_AUDIO);
	if (Spec == NULL)
		Spec = &DefaultAS;
	
	SDL_AudioSpec request = *Spec;
	
	request.callback = &callback;
	request.format = AUDIO_U8; // atm, we only support 8 bit audio....
	request.userdata = (void *) this;
	
	SDL_OpenAudio (&request, &AudSpec);
}

SAC120::~SAC120 (void) {
	SDL_CloseAudio ();
}

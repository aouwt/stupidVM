#include <SDL.h>
#include <SDL_audio.h>

#include "stupidVM.hpp"
#include "Peripheral.hpp"
#include "SAC120.hpp"

static const SDL_AudioSpec DefaultAS = {
	.freq = 44100,
	.format = AUDIO_U8,
	.samples = 512
};


static void callback (void *__this, uint8_t *stream, int len) {
	SAC120 *_this = (SAC120 *) __this;
	
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

static void pf_io (void *__this, Peripheral::PeripheralBus *bus) {
	SAC120 *_this = (SAC120 *) __this;
	
	if (bus -> RW == RW_WRITE) {
		_this -> Regs [bus -> addr] = bus -> word;
		
		if ((bus -> addr & 0x03) == 3) { // write to volume byte to push change
			U8 ch = (bus -> addr & 0xC) >> 2; // get top 2 bits
			
			_this -> Chs [ch].Samp = &_this -> Waveforms [_this -> Regs [ch + 2]];
			_this -> Chs [ch].Amp = _this -> Regs [ch + 3] / 256.0;
			_this -> Chs [ch].SampTime =
				(_this -> AudSpec.freq / // convert to samples
					(_this -> Regs [ch + 0] & (_this -> Regs [ch + 1] << 8)) // get frequency
				) / _this -> Chs [ch].Samp -> Len // convert to samptime
			;
		}
	} else
		bus -> word = _this -> Regs [bus -> addr];
}

static void construct (void *__this) {
	SAC120 *_this = (SAC120 *) __this;
	
	SDL_Init (SDL_INIT_AUDIO);
	SDL_AudioSpec request = DefaultAS;
	
	request.callback = &callback;
	request.format = AUDIO_U8; // atm, we only support 8 bit audio....
	request.userdata = __this;
	
	SDL_OpenAudio (&request, &_this -> AudSpec);
}

static void destruct (void *__this) {
	SDL_CloseAudio ();
}


const Peripheral::PeripheralInfo SAC120::PeripheralInfo = {
	.Constructor = &construct,
	.Destructor = &destruct,
	.IO = &pf_io,
	.Int = NULL,
	.Name = "SAC120"
};


#include <SDL.h>
#include <SDL_audio.h>

#include "stupidVM.h"
#include "Peripheral.h"
#include "SAC120.h"

static const SDL_AudioSpec DefaultAS = {
	.freq = 44100,
	.format = AUDIO_U8,
	.samples = 512
};


static void callback (void *this, uint8_t *stream, int len) {
	struct SAC120 *_ = (struct SAC120 *) this;
	
	for (int i = 0; i != len; i ++) {
		stream [i] = 0;
		
		for (U8 ch = 0; ch != 3; ch ++) {
			
			if (-- _->Chs [ch].ToNext == 0) {
				if (++ _->Chs [ch].CurSamp >= _->Chs [ch].Samp -> Len)
					_->Chs [ch].CurSamp = 0;
				_->Chs [ch].ToNext = _->Chs [ch].SampTime;
			}
			
			stream [i] += (_->Chs [ch].Samp -> Dat [_->Chs [ch].CurSamp]) * _->Chs [ch].Amp;
		}
		
	}
}

static void pf_io (void *this, PeripheralBus *bus) {
	struct SAC120 *_ = (struct SAC120 *) this;
	
	if (bus -> RW == RW_WRITE) {
		_->Regs [bus -> addr] = bus -> word;
		
		if ((bus -> addr & 0x03) == 3) { // write to volume byte to push change
			U8 ch = (bus->addr & 0xC) >> 2; // get top 2 bits
			
			_->Chs [ch].Samp = &_->Waveforms [_->Regs [ch + 2]];
			_->Chs [ch].Amp = _->Regs [ch + 3] / 256.0;
			_->Chs [ch].SampTime =
				(_->AudSpec.freq / // convert to samples
					(_->Regs [ch + 0] & (_->Regs [ch + 1] << 8)) // get frequency
				) / _->Chs [ch].Samp -> Len // convert to samptime
			;
		}
	} else
		bus -> word = _->Regs [bus -> addr];
}

static void construct (void *this) {
	struct SAC120 *_ = (struct SAC120 *) this;
	
	SDL_Init (SDL_INIT_AUDIO);
	SDL_AudioSpec request = DefaultAS;
	
	request.callback = &callback;
	request.format = AUDIO_U8; // atm, we only support 8 bit audio....
	request.userdata = this;
	
	SDL_OpenAudio (&request, &_->AudSpec);
}

static void destruct (void *_unused) {
	SDL_CloseAudio ();
}


const PeripheralInfo SAC120 = {
	.Constructor = &construct,
	.Destructor = &destruct,
	.IO = &pf_io,
	.Int = NULL,
	.Name = "SAC120"
};


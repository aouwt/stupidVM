#include <SDL.h>
#include <SDL_audio.h>
#include <math.h>

#include "stupidVM.h"
#include "Peripheral.h"
#include "SAC120.h"
#include "SAC120_Internal.h"


static const SDL_AudioSpec DefaultAS = {
	.freq = 44100,
	.format = AUDIO_U8,
	.samples = 512
};

static SAC120_Sample Waveforms [64] [256];

static void __attribute__((constructor)) genwaves (void) {
	U8 bases [64] [4];
	
	for (int samp = 0; samp != 64; samp ++) {
		bases [samp] [0] = (samp >= 32) ? 255 : 0; // square wave
		bases [samp] [1] = abs (samp - 32); // triangle / sawtooth
		bases [samp] [2] = rand () & 0xF0; // 16 bit noise
		bases [samp] [3] = (rand () & 1) ? 255 : 0; // 1 bit noise
	}
	
	for (int id = 0; id != 256; id ++) {
		U8 samp = 0;
		const U8 duty = id & 0x3F;
		const U8 base = (id & 0xC0) >> 6; // upper two bits are for waveform ID
		
		
		for (samp = 0; samp < duty; samp ++)
			Waveforms [samp] [id] = bases [samp] [base];
		
		for (; samp < 64; samp ++)
			Waveforms [samp] [id] = bases [samp - duty] [base];
	}
}

static void callback (void *this, uint8_t *stream, int len) {
	struct SAC120 *_ = (struct SAC120 *) this;
	
	for (int i = 0; i != len; i ++) {
		stream [i] = 0;
		
		for (U8 ch = 0; ch != 3; ch ++) {
			
			if (-- _->Chs [ch].ToNext == 0) {
				if (++ _->Chs [ch].CurSamp >= 64)
					_->Chs [ch].CurSamp = 0;
				_->Chs [ch].ToNext = _->Chs [ch].SampTime;
			}
			
			stream [i] += _->Chs [ch].Samp [_->Chs [ch].CurSamp] * _->Chs [ch].Amp;
		}
		
	}
}

static void pf_io (void *this, PeripheralBus *bus) {
	struct SAC120 *_ = (struct SAC120 *) this;
	
	if (bus -> RW == RW_WRITE) {
		_->Regs [bus -> addr] = bus -> word;
		
		if ((bus -> addr & 0x03) == 3) { // write to volume byte to push change
			U8 ch = (bus->addr & 0xC) >> 2; // get top 2 bits
			
			_->Chs [ch].Samp = Waveforms [_->Regs [ch + 2]];
			_->Chs [ch].Amp = _->Regs [ch + 3] / 256.0;
			_->Chs [ch].SampTime =
				(_->AudSpec.freq / // convert to samples
					(_->Regs [ch + 0] & (_->Regs [ch + 1] << 8)) // get frequency
				) / 64 // convert to samptime
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


static const PeripheralInfo SAC120 = {
	.Constructor = construct,
	.Destructor = destruct,
	.IO = pf_io,
	.Int = NULL,
	.Name = "SAC120",
	.Size = sizeof (struct SAC120)
};

const PeripheralInfo *P_ThisInfo = &SAC120;

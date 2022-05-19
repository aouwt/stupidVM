#include <SDL.h>
#include <SDL_audio.h>

#include "stupidVM.hpp"
#include "periphial.hpp"

const SDL_AudioSpec DefaultAS = {
	
};

void callback (void *udat, uint8_t *stream, int len) {
	SAC110 *_this = udat;
	
}

SAC110::SAC110 (SDL_AudioSpec *Spec) {
	SDL_Init (SDL_INIT_AUDIO);
	if (Spec == NULL)
		Spec = &DefaultAS;
	
	SDL_AudioSpec request = *Spec;
	
	request.callback = &callback;
	request.userdata = (void *) this;
	
	SDL_OpenAudio (&request, &AudSpec);
}

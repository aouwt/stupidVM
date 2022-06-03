#include <fcntl.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

#include "main.hpp"
#include "stupidVM.h"

void loadrom (const char *path) {
	FILE *f = fopen (path, "r");
	if (f == NULL) {
		fprintf (stderr, "There was an error trying to load ROM file '%s': %s\n", path, strerror (errno));
		return;
	}
	
	uint8_t *pos = &Memories::ASpace [0xA000];
	uint8_t *end = &Memories::ASpace [0xFF00];
	do
		pos += fread (pos, sizeof (uint8_t), end - pos, f);
	while (pos < end);
	
	fclose (f);
}

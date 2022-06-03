#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

#include "SMP100.hpp"
#include "Peripherals.hpp"
#include "periphcontrol.hpp"
#include "romloader.hpp"
#include "stupidVM_Supp.hpp"
#include "main.hpp"

SMP100 *CPU;
Peripherals *Perip;
static struct {
	void **Handles;
	int Count = 0;
} Dl;

uint8_t Memories::ASpace [0xFFFF];
uint8_t *Memories::Banks [0xFF] = {NULL};
U8 Memories::CurBank;


void cycle (void) {
	#define WRITE(to)	to [addr] = CPU -> Bus.word
	#define READ(from)	CPU -> Bus.word = from [addr]
	
	Address addr = CPU -> Bus.addr;
	CPU -> Cycle ();
	
	if ((addr >= 0x2000) && (addr < 0xA000)) {
		if (Memories::Banks [Memories::CurBank] != NULL) {
			if (CPU -> Bus.RW == RW_READ)
				READ (Memories::Banks [Memories::CurBank]);
			else {
				if (Memories::CurBank < 127)
					WRITE (Memories::Banks [Memories::CurBank]);
			}
		}
		
	} else
	if ((addr >= 0xA000) && (addr < 0xFF00)) { // SROM
		if (CPU -> Bus.RW == RW_READ)
			READ (Memories::ASpace);
	} else
	if (addr >= 0xFF00) {	// Peripheral
		Perip -> BusAction (&CPU -> Bus);
	} else {	// SRAM
		if (CPU -> Bus.RW == RW_READ)
			READ (Memories::ASpace);
		else
			WRITE (Memories::ASpace);
	}
	#undef WRITE
	#undef READ
}


void print_help (char *argv0) {
	#define _(...)	fprintf (stdout, __VA_ARGS__)
	
	_ ("Usage: %s [-v] [-h] [-p SO] [-c SVMRC] [-m BANK] [-f FREQ | -F] [[-r] ROM]\n", argv0);
	_ ("Refer to stupidVM(1) for more information.\n");
	
	#undef _
}


int parse_args (char *argv [], int argc) {
	for (int i = 1; i != argc; i ++) {
		if (argv [i] [0] == '-') { // is arg?
		
			const char *me;
			
			if (argv [i] [1] == '-') { // is long arg? if so, convert to short arg
				// Lookup table
				const struct {
					const char *l;
					const char *s;
				} lookup [] = {
					{ "help", "h" },
					{ "peripheral", "p" },
					{ NULL, "" }
				};
				
				int item = 0;
				for (; lookup [item].l != NULL; item ++) {
					if (strcmp (lookup [item].l, argv [i] + 2) == 0)
						break;
				}
				if (lookup [item].l == NULL)
					fprintf (stderr, "Unknown long argument '%s'\n", argv [i]);
				
				me = lookup [item].s;
			} else
				me = argv [i] + 1;
			
			// do stuff on short arg
			for (int c = 0; me [c] != '\0'; c ++) {
				switch (me [c]) {
					case 'l': { // -l --load-so	add new device
						void *hdl = (
							Dl.Handles [Dl.Count ++] = dlopen (argv [++ i], RTLD_NOW | RTLD_LOCAL)
						);
						if (hdl == NULL) {
							fprintf (stderr, "%s\n", dlerror ());
							break;
						}
						void *sym = dlsym (hdl, "P_ThisInfo");
						
						if (sym == NULL)
							fprintf (stderr, "%s\n", dlerror ());
						else
							Perip -> New (*((const PeripheralInfo **) sym));
					} break;
					
					case 'h': {
						print_help (argv [0]);
						return 1;
					} break;
					
					case 'm': {
						int b = atoi (argv [++ i]);
						for (int n = 0; n != b; n ++) {
							if (Memories::Banks [n] != NULL)
								Memories::Banks [n] = new uint8_t [32768];
						}
					} break;
					
					default: {
						fprintf (stderr, "Unknown argument '%c'. Run '%s --help' for more information.\n", me [c], argv [0]);
					} break;
				
				}
			}
				
		} else {
			loadrom (argv [i]);
		}
	}	
	return 0;
}

int main (int argc, char *argv []) {
	CPU = new SMP100 (0xA000, 0x1F00);
	Perip = new Peripherals;
	Perip -> New (&P_ThisInfo);
	Dl.Handles = new void * [argc];
	
	{	int ret = parse_args (argv, argc);
		if (ret)
			return ret;
	}
	
	CPU -> SignalReset ();
	Timer timer (8000); // in KHz
	
	while (true) {
		timer.Wait ();
		for (U16 i = 0; i != 1000; i ++)
			cycle ();
	}
	
	delete CPU;
	delete Perip;
	delete [] Dl.Handles;
}

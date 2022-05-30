#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

#include "SMP100.hpp"
#include "Peripherals.hpp"
#include "stupidVM_Supp.hpp"


static SMP100 *CPU;
static Peripherals *Perip;
static struct {
	void **Handles;
	int Count = 0;
} Dl;

namespace Memories {
	Word ASpace [0xFFFF];
	Word Banks [0xFF] [0x8000];
	U8 CurBank;
};


void cycle (void) {
	#define WRITE(to)	to [addr] = CPU -> Bus.word
	#define READ(from)	CPU -> Bus.word = from [addr]
	
	Address addr = CPU -> Bus.addr;
	CPU -> Cycle ();
	
	if ((addr >= 0x2000) && (addr < 0xA000)) {
		if (CPU -> Bus.RW == RW_READ)
			READ (Memories::Banks [Memories::CurBank]);
		else {
			if (Memories::CurBank < 127)
				WRITE (Memories::Banks [Memories::CurBank]);
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


int parse_args (char *argv [], int argc) {
	for (int i = 0; i != argc; i ++) {
		if (argv [i] [0] == '-') { // is arg?
		
			const char *me;
			
			if (argv [i] [1] == '-') { // is long arg? if so, convert to short arg
				// Lookup table
				const struct {
					const char *l;
					const char *s;
				} lookup [] = {
					{ "help", "h" },
					{ "load-so", "l" },
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
							Perip -> New ((const PeripheralInfo *) sym);
					} break;
					
					default: {
						fprintf (stderr, "Unknown argument '%c'\n", me [c]);
					} break;
				
				}
			}
				
		}
	}	
	return 0;
}

int main (int argc, char *argv []) {
	CPU = new SMP100 (0xA000, 0x1F00);
	Perip = new Peripherals;
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

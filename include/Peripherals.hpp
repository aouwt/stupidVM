#ifndef PERIPHERALS_HPP
	#define PERIPHERALS_HPP
	
	#include <stdint.h>
	
	#include "stupidVM.h"
	#include "Peripheral.h"
	class Peripherals {
		public:
			
			typedef S8 PeripheralID;
	
			PeripheralID New (const PeripheralInfo *Info);
			PeripheralID Add (const PeripheralInfo *Info);
			void Remove (PeripheralID ID);
			void Delete (PeripheralID ID);
			void PowerOn (PeripheralID ID);
			void PowerOff (PeripheralID ID);
			void BusAction (struct Pair *Bus);
			
			~Peripherals (void);
			Peripherals (void);
			
		private:
			struct {
				const PeripheralInfo *info;
				void *obj = NULL;
			} perip [16];
			
	};
#endif

#ifndef SMP100C_HPP
	#define SMP100C_HPP
	
	#include "stupidVM.hpp"
	#include "peripheral.hpp"
	#include "SMP100.hpp"
	class SMP100c {
		public:
			SMP100c (U16 ClockRate, U16 RAM);
			~SMP100c (void);
			void PeripheralFunc (PeripheralBus *bus);
			
			//"private"
			SMP100 *SMP;
			U16 RAMMask;
			U8* RAM;
	};
#endif

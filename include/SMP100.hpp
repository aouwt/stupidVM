#ifndef SMP100_HPP
	#define SMP100_HPP

	#include "stupidVM.hpp"
	class SMP100 {
		
		public:
			struct Pair Bus;
			
			struct {
				Address Reset;
				Address StackBegin;
			} HWReg;
			
			SMP100 (Address Reset, Address StackBegin) {
				HWReg.Reset = Reset;
				HWReg.StackBegin = StackBegin;
			}
			
			void SignalInt (short ID);
			void SignalReset (void);
			
			void Cycle (void);
			
			// "private" (needed public for the callbacks and stuff)
			struct {
				uint_fast16_t A;
				uint_fast16_t B;
				bool C;
				uint_fast32_t M;
				
				bool Carry;
				uint_fast32_t PC;
				uint_fast8_t StackPtr;
				
				uint_fast8_t IStor;
				uint_fast16_t IStor2;
				
				uint_fast16_t Ints [16];
				uint_fast16_t IntRet;
			} Reg;
			
			int_fast8_t NextInt = -1;
			typedef void (* OpFunc) (SMP100 *);
			
			static const OpFunc *Opcodes [];
			static const OpFunc Op_Reset [];
			static const OpFunc Op_BeginCycle [];
			const OpFunc *Operation = Opcodes [0xFF];
	};
#endif

#ifndef SMP100_HPP
	#define SMP100_HPP

	#include "stupidVM.h"
	class SMP100 {
		
		public:
			struct Pair Bus;	// Address and data bus. Important to check this after every call to Cycle ()!
			
			struct {	// Hardware registers, for aiding in the description of the CPU's behavior. Usually set with the constructor, but can be set afterwards too.
				Address Reset;
				Address StackBegin;
			} HWReg;
			
			SMP100 (Address Reset, Address StackBegin) {	// constructor
				HWReg.Reset = Reset;
				HWReg.StackBegin = StackBegin;
			}
			
			void SignalInt (U8 ID);	// Signals interrupt (to run when op is finished)
			void SignalReset (void);	// Signals reset (forces to run next time Cycle () is called)
			
			void Cycle (void);	// Runs next pending operation for CPU emulation. Make sure to check the bus for addressing!
			
			
			
			// "private" (needed public for the callbacks and stuff)
			struct {
				U16 A;
				U16 B;
				bool C;
				U32 M;
				
				bool Carry;
				U32 PC;
				U8 StackPtr;
				
				U8 IStor;
				U8 IStor2;
				
				U16 Ints [16];
				U16 IntRet;
			} Reg;
			
			S8 NextInt = -1;
			typedef void (* OpFunc) (SMP100 *);
			
			static const OpFunc *Opcodes [];
			static const OpFunc Op_Reset [];
			static const OpFunc Op_BeginCycle [];
			const OpFunc *Operation = Opcodes [0xFF];
	};
#endif

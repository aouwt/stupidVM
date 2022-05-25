#ifndef PERIPHERAL_HPP
	#define PERIPHERAL_HPP
	
	#include <stdint.h>
	
	#include "stupidVM.hpp"
	
	class Peripheral {
		public:
			struct PeripheralBus {
				bool RW;
				U8 addr;
				Word word;
			};
			
			struct PeripheralInfo {
				void (* Constructor) (void *);
				void (* Destructor) (void *);
				void (* IO) (void *, PeripheralBus *);
				void (* Int) (void *);
				char Name [16] = "";
			};
			
			typedef S8 PeripheralID;
			
			
			template <class device> PeripheralID New (void);
			template <class device> PeripheralID Add (void);
			void Remove (PeripheralID ID);
			void Delete (PeripheralID ID);
			void PowerOn (PeripheralID ID);
			void PowerOff (PeripheralID ID);
			
			~Peripheral (void);
			
		private:
			struct {
				PeripheralInfo *info;
				void *obj = NULL;
			} perip [16];
	};
#endif

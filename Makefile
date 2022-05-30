CALLED_DIRECTORY	:=	$(shell pwd)

COPTS	=	${GLOBALOPTS} -std=c++20 -funroll-loops -funroll-all-loops -Ofast -march=native -mtune=native -Wall -Wextra -Wpedantic -I${CALLED_DIRECTORY}/include -fPIC
LDOPTS	=	${GLOBALOPTS}

CC_O	=	cd $(@D) && cc ${COPTS} -c $(^F)
LD_O	=	ld ${LDOPTS} -no-pie -r $^ -o $@
LD_SO	=	ld ${LDOPTS} -shared -o $@ $^


SDL2_FLAGS	=	$(shell sdl2-config --cflags)
SDL2_LIBS	=	$(shell sdl2-config --libs)

LIBS	=	-lm -lstdc++ -lgcc -lSDL2 -ldl



all:	./stupidVM ./SAC120.so ./SMP100.so

./stupidVM:	./obj/main.o ./obj/SMP100.o ./obj/stupidVM.o
	cc ${COPTS} $^ -o $@ ${LIBS}


./obj/main.o:	./src/main.o;	${LD_O}
./obj/SMP100.o:	./src/SMP100/*.o;	${LD_O}
./obj/SAC120.o:	./src/SAC120/*.o;	${LD_O}
./obj/stupidVM.o:	./src/stupidVM/*.o;	${LD_O}

./SAC120.so:	./obj/SAC120.o;	${LD_SO} ${SDL2_LIBS}
./SMP100.so:	./obj/SMP100.o;	${LD_SO} ${SDL2_LIBS}

./src/main.o:	./src/main.cpp;	${CC_O}

./src/SMP100/%.o:	./src/SMP100/%.cpp;	${CC_O} ${SDL2_FLAGS}
./src/SAC120/%.o:	./src/SAC120/%.c;	${CC_O} ${SDL2_FLAGS}
./src/stupidVM/%.o:	./src/stupidVM/%.cpp;	${CC_O}


clean:
	rm -rf ./obj/* ./src/*.o ./src/*/*.o ./*.so

.PHONY: clean all

MAKE_O=cc ${COPTS} ${CPP} -r -no-pie -o $@

COPTS=-funroll-loops -funroll-all-loops -Ofast -march=native -mtune=native -Wall -Wextra -Wpedantic -I./include
CPP=-x c++

SDL2=$(shell sdl2-config --cflags)
SDL2_AUDIO=${SDL2}
SDL2_THREAD=${SDL2}

DEPS=-lstdc++ $(shell sdl2-config --libs)

./stupidVM: ./obj/main.o ./obj/SMP100.o ./obj/SAC120.o ./obj/SGC100.o ./obj/stupidVM.o
	cc ${COPTS} $^ ${DEPS} -o ./stupidVM


./obj:
	mkdir obj -p

./obj/main.o:	./obj; ${MAKE_O} ./src/*.cpp

./obj/SMP100.o:	./obj; ${MAKE_O} ${SDL2_THREAD} ./src/SMP100/*.cpp
./obj/SAC120.o:	./obj; ${MAKE_O} ${SDL2_AUDIO} ./src/SAC120/*.cpp
./obj/SGC100.o:	./obj; ${MAKE_O} ${SDL2} ./src/SGC100/*.cpp
./obj/stupidVM.o:	./obj; ${MAKE_O} ${SDL2} ./src/stupidVM/*.cpp

clean:
	rm -rf ./obj

.PHONY: clean

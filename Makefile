MAKE_O=cc ${COPTS} -r -no-pie -o $@

COPTS=-std=c++20 -funroll-loops -funroll-all-loops -Ofast -march=native -mtune=native -Wall -Wextra -Wpedantic -I./include

SDL2=$(shell sdl2-config --cflags)
SDL2_AUDIO=${SDL2}
SDL2_THREAD=${SDL2}

DEPS=-lstdc++ $(shell sdl2-config --libs)

./stupidVM: ./obj/main.o ./obj/SMP100.o ./obj/SAC120.o ./obj/stupidVM.o
	cc ${COPTS} $^ ${DEPS} -o ./stupidVM


./obj:
	mkdir obj -p

./obj/main.o:	./obj; ${MAKE_O} ${SDL2} ./src/*.c*

./obj/SMP100.o:	./obj; ${MAKE_O} ${SDL2_THREAD} ./src/SMP100/*.c*
./obj/SAC120.o:	./obj; ${MAKE_O} ${SDL2_AUDIO} ./src/SAC120/*.c*
./obj/stupidVM.o:	./obj; ${MAKE_O} ${SDL2} ./src/stupidVM/*.c*

clean:
	rm -rf ./obj

.PHONY: clean

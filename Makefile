MAKE_O=-r -no-pie -I./include
COPTS=-Ofast -std=c++20 -Wall -Wextra -Wpedantic
CPP=-x c++

SDL2_OPTS=$(shell sdl2-config --cflags)
SDL2_AUDIO_OPTS=${SDL2_OPTS}

./stupidVM: ./obj/main.o ./obj/SMP100.o
	cc ${COPTS} ./obj/*.o -o ./stupidVM

./obj:
	mkdir obj

./obj/main.o: ./obj
	cc ${COPTS} ${MAKE_O} ./src/main.cpp -o ./obj/main.o

./obj/SMP100.o: ./src/SMP100/SMP100.o ./src/SMP100/ops.o ./obj
	cc ${COPTS} ${MAKE_O} ./src/SMP100/SMP100.o ./src/SMP100/ops.o -o ./obj/SMP100.o

./src/SMP100/SMP100.o:
	cc ${COPTS} ${MAKE_O} ${CPP} ./src/SMP100/SMP100.cpp -o ./src/SMP100/SMP100.o

./src/SMP100/ops.o:
	cc ${COPTS} ${MAKE_O} ${CPP} ./src/SMP100/ops.cpp -o ./src/SMP100/ops.o

./src/SAC120/SAC120.o:
	cc ${COPTS} ${SDL2_AUDIO_OPTS} ${MAKE_O} ${CPP} ./src/SAC120/SAC120.cpp -o ./src/SAC120/SAC120.o

./obj/SAC120.o: ./src/SAC120/SAC120.o ./obj
	cc ${COPTS} ${SDL2_AUDIO_OPTS} ${MAKE_O} ./src/SAC120/SAC120.o -o ./obj/SAC120.o

clean:
	rm -rf ./obj ./src/*.o ./src/*/*.o

.PHONY: clean

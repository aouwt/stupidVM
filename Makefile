CALLED_DIRECTORY	:=	$(shell pwd)

COPTS	=	${GLOBALOPTS} $(if ${OPTIMIZE},-Ofast -march=native -mtune=native -Wall -Wextra -Wpedantic -funroll-loops -funroll-all-loops) -I${CALLED_DIRECTORY}/include -fPIC
CXXOPTS	=	${COPTS} -std=c++20
LDOPTS	=	${GLOBALOPTS}

CC_O	=	cd $(@D) && cc ${COPTS} -c $(^F)
LD_O	=	ld ${LDOPTS} -no-pie -r $^ -o $@
LD_SO	=	ld ${LDOPTS} -shared -o $@ $^


SDL2_FLAGS	=	$(shell sdl2-config --cflags)
SDL2_LIBS	=	$(shell sdl2-config --libs)
CXX_LIBS	=	-lc++

LIBS	=	-lm ${SDL2_LIBS} ${CXX_LIBS} -ldl



all:	./stupidVM ./SAC120.so ./SMP100c.so

debug:	GLOBALOPTS += -g
debug:	all ./logger.so

./stupidVM:	./obj/main.o ./obj/SMP100.o ./obj/stupidVM.o ./obj/periphcontrol.o
	cc ${COPTS} $^ -o $@ ${LIBS}


./obj/main.o:	./src/main.o;	${LD_O}
./obj/periphcontrol.o:	./src/periphcontrol.o;	${LD_O}
./obj/SMP100.o:	./src/SMP100/*.o;	${LD_O}
./obj/SAC120.o:	./src/SAC120/*.o;	${LD_O}
./obj/stupidVM.o:	./src/stupidVM/*.o;	${LD_O}

./SAC120.so:	./obj/SAC120.o;	${LD_SO} ${SDL2_LIBS}
./SMP100c.so:	./obj/SMP100.o;	${LD_SO} ${SDL2_LIBS} ${CXX_LIBS}
./logger.so:	./src/debug/log.o;	${LD_SO};

./src/main.o:	./src/main.cpp;	${CC_O} ${CXXOPTS}
./src/periphcontrol.o:	./src/periphcontrol.cpp;	${CC_O} ${CXXOPTS}

./src/SMP100/%.o:	./src/SMP100/%.cpp;	${CC_O} ${CXXOPTS} ${SDL2_FLAGS}
./src/SAC120/%.o:	./src/SAC120/%.c;	${CC_O} ${SDL2_FLAGS}
./src/stupidVM/%.o:	./src/stupidVM/%.cpp;	${CC_O} ${CXXOPTS}
./src/debug/%.o:	./src/debug/%.c;	${CC_O}

clean:
	rm -rf ./obj/* ./src/*.o ./src/*/*.o ./*.so

.PHONY: clean all debug

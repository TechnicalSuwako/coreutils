NAME=ls
VERSION := $(shell cat ../Makefile | grep "VERSION=" | sed 's/VERSION=//')
SRC=${NAME}.zig
CC=zig build-exe
RELEASE=ReleaseSmall

all:
	${CC} ${SRC} -O ${RELEASE} --name ${NAME}

clean:
	rm -f ${NAME} ${NAME}.o

.PHONY: all clean

NAME=coreutils
VERSION := $(shell cat version.zig | grep "pub const version" | awk '{print $$5}' | sed "s/\"//g" | sed "s/;//")
PREFIX=/usr
MANPREFIX=${PREFIX}/share/man
PROG=cat cp ls mkdir pwd rm touch
CC=zig build-exe
RELEASE=ReleaseSmall

all: ${PROG}

%: %.zig
	mkdir -p bin
	${CC} $< -O ${RELEASE} --name $@
	mv $@ bin
	mv $@.o bin

clean:
	rm -rf bin/${PROG}

.PHONY: all clean

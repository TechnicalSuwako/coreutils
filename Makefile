NAME=coreutils
VERSION := $(shell cat version.zig | grep "const version" | awk '{print $$4}' | sed "s/\"//g" | sed "s/;//")
PREFIX=/usr
MANPREFIX=${PREFIX}/share/man
PROG=basename cat cp dirname echo false groups ls mkdir pwd rm touch true wc whoami
CC=zig build-exe
RELEASE=ReleaseSmall

all: ${PROG}

%: %.zig
	mkdir -p bin
	${CC} $< -O ${RELEASE} --name $@
	mv $@ bin
	mv $@.o bin

loc-install: all
	mkdir -p ~/.local/bin
	for prog in ${PROG}; do \
		cp bin/$$prog ~/.local/bin; \
		chmod +x ~/.local/bin/$$prog; \
	done

sys-install: all
	mkdir -p ${PREFIX}/bin
	for prog in ${PROG}; do \
		cp bin/$$prog ${PREFIX}/bin; \
		chmod +x ${PREFIX}/bin/$$prog; \
	done

clean:
	rm -rf bin/${PROG}

.PHONY: all loc-install sys-install clean

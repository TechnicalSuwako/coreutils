NAME=coreutils
VERSION=0.0.1
PREFIX=/usr
MANPREFIX=${PREFIX}/share/man

all:
	mkdir bin
	cd cat && make && mv cat ../bin && rm -rf cat.o && cd ..
	cd cp && make && mv cp ../bin && rm -rf cp.o && cd ..
	cd ls && make && mv ls ../bin && rm -rf ls.o && cd ..
	cd pwd && make && mv pwd ../bin && rm -rf pwd.o && cd ..
	cd rm && make && mv rm ../bin && rm -rf rm.o && cd ..
	cd touch && make && mv touch ../bin && rm -rf touch.o && cd ..

clean:
	rm -rf bin

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f bin/* ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/cat
	chmod 755 ${DESTDIR}${PREFIX}/bin/cp
	chmod 755 ${DESTDIR}${PREFIX}/bin/ls
	chmod 755 ${DESTDIR}${PREFIX}/bin/pwd
	chmod 755 ${DESTDIR}${PREFIX}/bin/rm
	chmod 755 ${DESTDIR}${PREFIX}/bin/touch
	#mkdir -p ${DESTDIR}${MANPREFIX}/man1
	#sed "s/VERSION/${VERSION}/g" < ${NAME}.1 > ${DESTDIR}${MANPREFIX}/man1/${NAME}.1
	#chmod 644 ${DESTDIR}${MANPREFIX}/man1/${NAME}.1

.PHONY: all clean dist install

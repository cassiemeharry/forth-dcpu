all: forth-core.o
	dtld -l image -o forth-core.bin forth-core.o
forth-core.o: forth-core.dasm forth-macros.m4
	m4 forth-core.dasm | dtasm -i -o forth-core.o -
clean:
	rm -rf *.bin *.o

CC=gcc
CFLAGS=-g -Wall -I$(HOME)/scripts/c/include
LDFLAGS=-lpthread

.PHONY: all clean

clean:
	-rm *.o

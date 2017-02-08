CC=gcc
COFLAGS=
CWFLAGS=
CIFLAGS=
CMFLAGS=
CFLAGS= $(CWFLAGS) $(COFLAGS) $(CIFLAGS) $(CMFLAGS)
beautify: beautify.o
	$(CC) $(CFLAGS) -o beautify $<
.c.o:
	$(CC) $(CFLAGS) -c $<
beautify.c: beautify.l
	flex -o beautify.c beautify.l

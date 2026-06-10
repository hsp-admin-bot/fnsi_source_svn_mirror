HED	= nkklib.h
OBJ	= timelib.o codelib.o numlib.o loglib.o

#---- NKKLIB ----
nkklib.a: $(OBJ)
	ar -r nkklib.a $(OBJ)

timelib.o:timelib.c
	gcc -c timelib.c

codelib.o:codelib.c
	gcc -c codelib.c

numlib.o:numlib.c
	gcc -c numlib.c

loglib.o:loglib.c
	gcc -c loglib.c


SYSTEM     = x86-64_linux
LIBFORMAT  = static_pic

#------------------------------------------------------------
#
# When you adapt this makefile to compile your CPLEX programs
# please copy this makefile and set CPLEXDIR and CONCERTDIR to
# the directories where CPLEX and CONCERT are installed.
#
#------------------------------------------------------------

CPLEXDIR      = /opt/ibm/ILOG/CPLEX_Studio1263/cplex
#CPLEXDIR      = /work/projects/cplex/soft/cplex/12.6.3/cplex/
#CONCERTDIR    = ../../../../concert

# ---------------------------------------------------------------------
# Compiler selection 
# ---------------------------------------------------------------------


CC  = mpicc -O3 -fopenmp


# ---------------------------------------------------------------------
# Compiler options 
# ---------------------------------------------------------------------

CCOPT = -m64 -O -fPIC -fno-strict-aliasing -fexceptions -DNDEBUG -DIL_STD


# ---------------------------------------------------------------------
# Link options and libraries
# ---------------------------------------------------------------------

CPLEXBINDIR   = $(CPLEXDIR)/bin/$(BINDIST)
CPLEXJARDIR   = $(CPLEXDIR)/lib/cplex.jar
CPLEXLIBDIR   = $(CPLEXDIR)/lib/$(SYSTEM)/$(LIBFORMAT)


CCLNDIRS  = -L$(CPLEXLIBDIR) -L$(CONCERTLIBDIR)
CLNDIRS   = -L$(CPLEXLIBDIR)
CCLNFLAGS = -lconcert -lilocplex -lcplex -lm -lpthread
CLNFLAGS  = -lcplex -lm -lpthread -lrt



all:
	make all_c

#execute: all
#	make execute_c


CPLEXINCDIR   = $(CPLEXDIR)/include

EXDIR         = $(CPLEXDIR)/examples
EXINC         = $(EXDIR)/include
EXDATA        = $(EXDIR)/data
#EXDATA        = /home/marouen.benguebila/P:/Projects/veryfastFVA
EXSRCC        = $(EXDIR)/src/c
EXSRCC        = ./
#EXSRCC        = /home/marouen.benguebila/P:/Projects/veryfastFVA


CFLAGS  = $(COPT)  -I$(CPLEXINCDIR)

#------------------------------------------------------------
#  make all      : to compile the examples. 
#  make execute  : to compile and execute the examples.
#------------------------------------------------------------

C_EX = veryfastFVAstatic veryfastFVAc50 veryfastFVAc100 veryfastFVAc500 veryfastFVAguided 

all_c: clean $(C_EX)

clean:
	rm -f *.o
	rm -rf $(C_EX)
	echo Clean done

# ------------------------------------------------------------
#
# The examples
#

veryfastFVAstatic: veryfastFVAstatic.o
	$(CC) $(CFLAGS) $(CLNDIRS) -o veryfastFVAstatic veryfastFVAstatic.o $(CLNFLAGS)
veryfastFVAstatic.o: $(EXSRCC)/veryfastFVAstatic.c
	$(CC) -c $(CFLAGS) veryfastFVAstatic.c -o veryfastFVAstatic.o

veryfastFVAc50: veryfastFVAc50.o
	$(CC) $(CFLAGS) $(CLNDIRS) -o veryfastFVAc50 veryfastFVAc50.o $(CLNFLAGS)
veryfastFVAc50.o: $(EXSRCC)/veryfastFVAc50.c
	$(CC) -c $(CFLAGS) veryfastFVAc50.c -o veryfastFVAc50.o

veryfastFVAc100: veryfastFVAc100.o
	$(CC) $(CFLAGS) $(CLNDIRS) -o veryfastFVAc100 veryfastFVAc100.o $(CLNFLAGS)
veryfastFVAc100.o: $(EXSRCC)/veryfastFVAc100.c
	$(CC) -c $(CFLAGS) veryfastFVAc100.c -o veryfastFVAc100.o

veryfastFVAc500: veryfastFVAc500.o
	$(CC) $(CFLAGS) $(CLNDIRS) -o veryfastFVAc500 veryfastFVAc500.o $(CLNFLAGS)
veryfastFVAc500.o: $(EXSRCC)/veryfastFVAc500.c
	$(CC) -c $(CFLAGS) veryfastFVAc500.c -o veryfastFVAc500.o

veryfastFVAguided: veryfastFVAguided.o
	$(CC) $(CFLAGS) $(CLNDIRS) -o veryfastFVAguided veryfastFVAguided.o $(CLNFLAGS)
veryfastFVAguided.o: $(EXSRCC)/veryfastFVAguided.c
	$(CC) -c $(CFLAGS) veryfastFVAguided.c -o veryfastFVAguided.o
# Local Variables:
# mode: makefile
# End:

SYSTEM     = x86-64_linux
LIBFORMAT  = static_pic

#------------------------------------------------------------
#
# When you adapt this makefile to compile your CPLEX programs
# please copy this makefile and set CPLEXDIR and CONCERTDIR to
# the directories where CPLEX and CONCERT are installed.
#
#------------------------------------------------------------

CPLEXDIR       = /home/travis/travis/cplex
#CPLEXDIR      = /opt/ibm/ILOG/CPLEX_Studio1271/cplex
#CPLEXDIR      = /work/projects/cplex/soft/cplex/12.6.3/cplex/

# ---------------------------------------------------------------------
# Compiler selection 
# ---------------------------------------------------------------------

ifndef TRAVIS
	CC  = mpicc -O3 -fopenmp -coverage
else
	CC  = mpicc -O3 -fopenmp 
endif

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


CLNDIRS   = -L$(CPLEXLIBDIR)
CCLNFLAGS = -lconcert -lilocplex -lcplex -lm -lpthread
CLNFLAGS  = -lcplex -lm -lpthread -lrt



ll:
	make all_c

#execute: all
#	make execute_c


CPLEXINCDIR   = $(CPLEXDIR)/include

EXDIR         = $(CPLEXDIR)/examples
EXINC         = $(EXDIR)/include
EXDATA        = $(EXDIR)/data
EXSRCC        = $(EXDIR)/src/c
EXSRCC        = ./


CFLAGS  = $(COPT)  -I$(CPLEXINCDIR)

#------------------------------------------------------------
#  make all      : to compile the examples. 
#  make execute  : to compile and execute the examples.
#------------------------------------------------------------

C_EX = veryfastFVA

all_c: clean $(C_EX)

clean:
	rm -f *.o
	rm -rf $(C_EX)
	echo Clean done

# ------------------------------------------------------------
#
# The examples
#

veryfastFVA: veryfastFVA.o
	$(CC) $(CFLAGS) $(CLNDIRS) -o veryfastFVA veryfastFVA.o $(CLNFLAGS)
veryfastFVA.o: $(EXSRCC)/veryfastFVA.c
	$(CC) -c $(CFLAGS) veryfastFVA.c -o veryfastFVA.o
# Local Variables:
# mode: makefile
# End:

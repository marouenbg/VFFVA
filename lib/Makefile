UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

ifeq ($(UNAME_S),Darwin)
  ifeq ($(UNAME_M),arm64)
    SYSTEM    = arm64_osx
  else
    SYSTEM    = x86-64_osx
  endif
else
  SYSTEM    = x86-64_linux
endif
LIBFORMAT  = static_pic

# Solver selection: set SOLVER=glpk to use GLPK, default is cplex
SOLVER ?= cplex

#------------------------------------------------------------
#
# When you adapt this makefile to compile your CPLEX programs
# please copy this makefile and set CPLEXDIR and CONCERTDIR to
# the directories where CPLEX and CONCERT are installed.
#
#------------------------------------------------------------

#Please define CPLEX path here
CPLEXDIR      ?= $(HOME)/Applications/CPLEX_Studio2212/cplex

# GLPK paths (override as needed)
ifeq ($(UNAME_S),Darwin)
GLPKINCDIR ?= /opt/homebrew/include
GLPKLIBDIR ?= /opt/homebrew/lib
else
GLPKINCDIR ?= /usr/include
GLPKLIBDIR ?= /usr/lib
endif

# ---------------------------------------------------------------------
# Compiler selection 
# ---------------------------------------------------------------------

ifeq ($(UNAME_S),Darwin)
	CC  = mpicc -O3 -Xclang -fopenmp -I/opt/homebrew/opt/libomp/include -L/opt/homebrew/opt/libomp/lib -lomp
else
	CC  = mpicc -O3 -fopenmp
endif

# Optional: compile with coverage (set COVERAGE=1)
ifdef COVERAGE
	CC += --coverage
endif

# ---------------------------------------------------------------------
# Compiler options 
# ---------------------------------------------------------------------

CCOPT = -m64 -O -fPIC -fno-strict-aliasing -fexceptions -DNDEBUG -DIL_STD


# ---------------------------------------------------------------------
# Link options and libraries
# ---------------------------------------------------------------------

ifeq ($(SOLVER),glpk)
CFLAGS  = $(COPT) -DUSE_GLPK -I$(GLPKINCDIR)
CLNDIRS = -L$(GLPKLIBDIR)
CLNFLAGS = -lglpk -lm -lpthread
else
CPLEXBINDIR   = $(CPLEXDIR)/bin/$(BINDIST)
CPLEXJARDIR   = $(CPLEXDIR)/lib/cplex.jar
CPLEXLIBDIR   = $(CPLEXDIR)/lib/$(SYSTEM)/$(LIBFORMAT)
CPLEXINCDIR   = $(CPLEXDIR)/include
CFLAGS  = $(COPT) -I$(CPLEXINCDIR)
CLNDIRS = -L$(CPLEXLIBDIR)
CCLNFLAGS = -lconcert -lilocplex -lcplex -lm -lpthread
ifeq ($(UNAME_S),Darwin)
CLNFLAGS  = -lcplex -lm -lpthread -ldl
else
CLNFLAGS  = -lcplex -lm -lpthread -lrt -ldl
endif
endif

EXSRCC = ./


ll:
	make all_c

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

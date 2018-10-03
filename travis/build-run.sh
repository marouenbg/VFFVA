#! /bin/sh

# Exit on error
set -ev

os=`uname`
TRAVIS_ROOT="$1"
MPI_IMPL="$2"

# Environment variables
export CFLAGS="-std=c99"
#export MPICH_CC=$CC
export MPICC=mpicc

case "$os" in
    Linux)
       export PATH=$TRAVIS_ROOT/open-mpi/bin:$PATH
       ;;
esac

# Capture details of build
case "$MPI_IMPL" in
    openmpi)
	cd lib
	make
	#simple test
	#1 core 2 threads
	mpirun -np 1 --bind-to none -x OMP_NUM_THREADS=2 ./veryfastFVA ../data/models/Ecoli_core/Ecoli_core.mps
        export TMPDIR=/tmp
        ;;
esac

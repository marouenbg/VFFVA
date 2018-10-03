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
        # this is missing with Mac build it seems
        #ompi_info --arch --config
        mpicc --showme:command
	cd $TRAVIS_ROOT
	ls
	cd ibm
	ls
	cd ILOG
        # see https://github.com/open-mpi/ompi/issues/2956
        # fixes issues e.g. https://travis-ci.org/jeffhammond/armci-mpi/jobs/211165004
        export TMPDIR=/tmp
        ;;
esac

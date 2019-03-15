# Installation guide

VFFVA is supported in Linux systms in both C and MATLAB.

## C

The C implementation is a hybrid MPI/OpenMP code that has two levels of parallelism in both shared memory
and non-shared memory systems.

### Requirements
+ Linux-based system.

+ IBM CPLEX 12.6.3. and above [Free academic version.](http://www-03.ibm.com/software/products/fr/ibmilogcpleoptistud)

+ OpenMP comes be default in the latest gcc version.

+ MPI through the OpenMPI 1.10.3 implementation.

### Quick install

```
cd lib
source ./install.sh
make
```
### Troubleshooting
Quick install downloads and installs 1) OpenMPI and 2) IBM CPLEX for 64-bit machines.

You can do each step separately if quick install did not work of if you have different machine specs.

+ MPI: You can use the following code snippet to install MPI

You might also need to add MPI path.

```
export PATH =$HOME/open-mpi/bin:$PATH
```
+ IBM CPLEX:

## MATLAB

VFFVA.m is the MATLAB implementation that consists of a wrapper around the C version.

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

+ MPI: You can use the following code snippet to install MPI
```
VERSION=3.1.2
wget --no-check-certificate https://www.open-mpi.org/software/ompi/v3.1/downloads/openmpi-$VERSION.tar.gz
tar -xzf openmpi-$VERSION.tar.gz
cd openmpi-$VERSION
mkdir build && cd build
../configure CFLAGS="-w" --prefix=$HOME/open-mpi \
             --without-verbs --without-fca --without-mxm --without-ucx \
             --without-portals4 --without-psm --without-psm2 \
             --without-libfabric --without-usnic \
             --without-udreg --without-ugni --without-xpmem \
             --without-alps --without-munge \
             --without-sge --without-loadleveler --without-tm \
             --without-lsf --without-slurm \
             --without-pvfs2 --without-plfs \
             --without-cuda --disable-oshmem \
             --disable-mpi-fortran --disable-oshmem-fortran \
             --disable-libompitrace \
             --disable-mpi-io  --disable-io-romio \
             --disable-static #--enable-mpi-thread-multiple
make -j2
make install
```
You might also need to add MPI path

```
export PATH=$HOME/open-mpi/bin:$PATH
```
+ IBM CPLEX: The recommended approach is to download [IBM CPLEX](http://www-03.ibm.com/software/products/fr/ibmilogcpleoptistud) and register for the free academic version.

Make sure that the CPLEXDIR path in `lib/Makefile` corresponds to the installation folder of CPLEX.

+ Once the required dependencies installed, `cd VFFVA/lib` then `make` at the root of `lib`.

+ Alternatively, you can open an issue [here](https://github.com/marouenbg/VFFVA/issues).

## MATLAB

VFFVA.m is the MATLAB implementation that consists of a wrapper around the C version.

### Requirements
+ Linux-based system.

+ MATLAB

+ IBM CPLEX 12.6.3. and above [Free academic version.](http://www-03.ibm.com/software/products/fr/ibmilogcpleoptistud)

+ OpenMP comes be default in the latest gcc version.

+ MPI through the OpenMPI 1.10.3 implementation.

### Quick install

```
cd lib
source ./install.sh
make
```


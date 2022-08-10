# Installation guide

VFFVA is supported in Linux systms in both C and MATLAB.

## C

The C implementation is a hybrid MPI/OpenMP code that has two levels of parallelism in both shared memory
and non-shared memory systems.

### Requirements
+ Linux-based system (tested on Ubuntu 16.04, 18.04, and 22.04).

+ IBM CPLEX 12.6.3. (tested on 12.6.3, 12.10, and 22.1.0) and above [Free academic version.](http://www.ibm.com/academic)

+ OpenMP comes be default in the latest gcc version (For macOs, OpenMp has to be installed separately)

+ MPI through the OpenMPI 1.10.3 implementation.

### Installation
You need to download and install 1) OpenMPI and 2) IBM CPLEX for 64-bit machines.

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
+ IBM CPLEX: The recommended approach is to download [IBM CPLEX](http://www.ibm.com/academic) and register for the free academic version.

Here is a code snippet for installing CPLEX for Ubunutu, this is only an example and you need to get your installation file after creating an IBMid.
In this example, CPLEX will be installed in ~/CPLEX_Studio1210.

```
VERSION_CPLEX=1210
wget "https://ak-dsw-mul.dhe.ibm.com/sdfdl/v2/fulfill/CC439ML/Xa.2/Xb.XwdHXGdhWvrm/Xc.CC439ML/cplex_studio1210.linux-x86-64.bin/Xd./Xf.lPr.D1VC/Xg.10736638/Xi./XY.scholars/XZ.UBs6UV1K_zA_5uS6T9I81YuWNmI/cplex_studio1210.linux-x86-64.bin#anchor"
chmod +x cplex_studio$VERSION_CPLEX.linux-x86-64.bin

#specify install options
echo "INSTALLER_UI=silent\n 
INSTALLER_LOCALE=en\n
LICENSE_ACCEPTED=true\n
USER_INSTALL_DIR=$HOME/CPLEX_Studio$VERSION_CPLEX"> myresponse.properties

#work around installation bug
export PS1=">"

#install
./cplex_studio$VERSION_CPLEX.linux-x86-64.bin -f "./myresponse.properties"

```
Then, make sure that the CPLEXDIR path in `lib/Makefile` corresponds to the installation folder of CPLEX (~/CPLEX_Studio1210 in the previous example).

+ Once the required dependencies installed, `cd VFFVA/lib` then `make` at the root of `lib`.

+ Alternatively, you can open an issue [here](https://github.com/marouenbg/VFFVA/issues).

## MATLAB

VFFVA.m is the MATLAB implementation that consists of a wrapper around the C version.

### Requirements
+ Linux-based system.

+ MATLAB

+ IBM CPLEX 12.6.3. and above [Free academic version.](http://www.ibm.com/academic)

+ OpenMP comes be default in the latest gcc version.

+ MPI through the OpenMPI 1.10.3 implementation.

### Installation

First, istall the C version, then add the path of the installed C version to your MATLAB path.

```
addpath(genpath('VFFVA'))
```

## Python

VFFVA.py is the Python3 implementation that consists of a wrapper around the C version.

### Requirements
+ Linux-based system.

+ Python 3

+ IBM CPLEX 12.6.3. and above [Free academic version.](http://www.ibm.com/academic)

+ OpenMP comes be default in the latest gcc version.

+ MPI through the OpenMPI 1.10.3 implementation.

### Installation

First, istall the C version, then add the path of the installed C version to your Python path.

## FAQ

- In MacOS, I get the error “Clang: Error: Unsupported Option ‘-Fopenmp’” Error
-> In MacOS, OpenMP is not provided by default, therefore you need to install it by updating to the latest version of llvm.

- Too many output arguments with function BuildMPS
-> The version of BuildMPS function provided with VFFVA gives 2 outputs, if you have the COBRAtoolbox in your path, you might be using another version that gives 1 output.
Therefore, make sure that VFFVA path supersedes COBRAtoolbox path in MATLAB path.
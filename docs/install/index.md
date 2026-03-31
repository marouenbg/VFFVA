# Installation guide

VFFVA is supported on Linux and macOS in C, MATLAB, and Python.

## C

The C implementation uses MPI for inter-node parallelism and OpenMP for intra-node parallelism (CPLEX backend)
or MPI-only parallelism (GLPK backend).

### Requirements
+ Linux-based system (tested on Ubuntu 16.04, 18.04, and 22.04) or macOS (tested on macOS ARM64).

+ **Solver (one of the following):**
  + IBM CPLEX 12.6.3 and above (tested on 12.6.3, 12.10, and 22.1.2) [Free academic version.](http://www.ibm.com/academic)
  + GLPK 4.65 and above (tested on 5.0) — free and open-source.

+ OpenMP comes by default in the latest gcc version. On macOS, install `libomp` via Homebrew: `brew install libomp`.

+ MPI through the OpenMPI implementation (tested on 1.10.3 and 5.0.9).

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

Here is a code snippet for installing CPLEX for Ubuntu, this is only an example and you need to get your installation file after creating an IBMid.
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

+ **GLPK** (alternative to CPLEX): Install via your package manager:
  + Ubuntu/Debian: `sudo apt-get install libglpk-dev`
  + macOS: `brew install glpk`

+ Once the required dependencies are installed, `cd VFFVA/lib` then build:
  + With CPLEX (default): `make`
  + With GLPK: `make SOLVER=glpk`

The Makefile auto-detects the platform (Linux/macOS, x86-64/ARM64) and sets the appropriate library paths.

+ Alternatively, you can open an issue [here](https://github.com/marouenbg/VFFVA/issues).

## MATLAB

VFFVA.m is the MATLAB implementation that consists of a wrapper around the C version.

### Requirements
+ Linux or macOS.

+ MATLAB

+ IBM CPLEX or GLPK (see C requirements above).

+ OpenMP comes by default in the latest gcc version. On macOS, install `libomp` via Homebrew.

+ MPI through the OpenMPI implementation.

### Installation

First, istall the C version, then add the path of the installed C version to your MATLAB path.

```
addpath(genpath('VFFVA'))
```

## Python

VFFVA.py is the Python3 implementation that consists of a wrapper around the C version.

### Requirements
+ Linux or macOS.

+ Python 3

+ IBM CPLEX or GLPK (see C requirements above).

+ OpenMP comes by default in the latest gcc version. On macOS, install `libomp` via Homebrew.

+ MPI through the OpenMPI implementation.

### Installation

First, istall the C version, then add the path of the installed C version to your Python path.

## FAQ

- In MacOS, I get the error “Clang: Error: Unsupported Option ‘-Fopenmp’” Error
-> In macOS, OpenMP is not provided by default. Install libomp via Homebrew: `brew install libomp`. The Makefile auto-detects macOS and uses the correct compiler flags.

- Too many output arguments with function BuildMPS
-> The version of BuildMPS function provided with VFFVA gives 2 outputs, if you have the COBRAtoolbox in your path, you might be using another version that gives 1 output.
Therefore, make sure that VFFVA path supersedes COBRAtoolbox path in MATLAB path.
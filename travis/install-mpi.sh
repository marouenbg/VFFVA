#!/bin/sh
# This configuration file was taken originally from the mpi4py project
# <http://mpi4py.scipy.org/>, and then modified for Julia

set -e
set -x

os=`uname`
TRAVIS_ROOT="$1"
MPI_IMPL="$2"

# this is where updated Autotools will be for Linux
export PATH=$TRAVIS_ROOT/bin:$PATH

case "$os" in
    Linux)
        echo "Linux"
        case "$MPI_IMPL" in
            openmpi)
                if [ ! -d "$TRAVIS_ROOT/open-mpi" ]; then
                    VERSION=3.1.2
                    wget --no-check-certificate https://www.open-mpi.org/software/ompi/v3.1/downloads/openmpi-$VERSION.tar.gz
                    tar -xzf openmpi-$VERSION.tar.gz
                    cd openmpi-$VERSION
                    mkdir build && cd build
                    ../configure CFLAGS="-w" --prefix=$TRAVIS_ROOT/open-mpi \
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
                else
                    echo "Open-MPI already installed"
                fi
                ;;
            *)
                echo "Unknown MPI implementation: $MPI_IMPL"
                exit 20
                ;;
        esac
        ;;
esac

#install IBM CPLEX
VERSION_CPLEX=1210
wget "https://ak-dsw-mul.dhe.ibm.com/sdfdl/v2/fulfill/CC439ML/Xa.2/Xb.XwdHXGddWvrm/Xc.CC439ML/cplex_studio1210.linux-x86-64.bin/Xd./Xf.lPr.D1VC/Xg.10615575/Xi./XY.scholars/XZ.unQjp7Yeq28Xo4Z12DgJGXx--L4/cplex_studio1210.linux-x86-64.bin#anchor"
chmod +x cplex_studio$VERSION_CPLEX.linux-x86-64.bin

#specify install options
echo "INSTALLER_UI=silent\n 
INSTALLER_LOCALE=en\n
LICENSE_ACCEPTED=true\n
USER_INSTALL_DIR=$TRAVIS_ROOT"> myresponse.properties

#work arounf installation bug
export PS1=">"

#install
./cplex_studio$VERSION_CPLEX.linux-x86-64.bin -f "./myresponse.properties"

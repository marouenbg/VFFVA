#!/bin/sh                    

#1. install OpenMPI
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

export PATH=$HOME/open-mpi/bin:$PATH

#2. install IBM CPLEX
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

#Sometimes path does not get updated
export PATH=$HOME/open-mpi/bin:$PATH

#Clean files
rm -rf cplex_studio$VERSION_CPLEX.linux-x86-64.bin
rm -rf ../../openmpi-$VERSION
rm -rf ../../openmpi-$VERSION.tar.gz


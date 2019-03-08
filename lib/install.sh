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
VERSION_CPLEX=12.7.1
wget "https://ak-dsw-mul.dhe.ibm.com/sdfdl/v2/fulfill/CNI55ML/Xa.2/Xb.wzt5iJcvdsf_6y3jnv4KVpeZrR1ITpFqw_nGoUyO9WgOsMy3zfirXa-luwtfb9Wxyg/Xc.CNI55ML/cplex_studio12.7.1.linux-x86-64.bin/Xd./Xf.lPr.D1VC/Xg.15048651/Xi.kivuto/XY.scholars/XZ.Kt3-euG55mrPls29B3kHipq8x0U/cplex_studio12.7.1.linux-x86-64.bin"
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

#Clean files
rm -rf cplex_studio$VERSION_CPLEX.linux-x86-64.bin
rm -rf ../../openmpi-$VERSION
rm -rf ../../openmpi-$VERSION.tar.gz


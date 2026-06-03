#!/bin/bash

export CFLAGS="${CFLAGS} -Wno-error=implicit-function-declaration \
                        -Wno-error=incompatible-pointer-types \
                        -Wno-error=implicit-int"
if [[ "$(uname)" == "Linux" ]]; then
  export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include/tirpc"
  export LDFLAGS="${LDFLAGS} -ltirpc"
fi
if [[ "$(uname)" == "Darwin" ]]; then
  export LDFLAGS="${LDFLAGS} -Wl,-flat_namespace -Wl,-undefined,suppress"
fi

autoreconf -vfi

# The --enable-silent-rules is needed because Travis CI dies on the long output from this build.

if [[ $(uname -m) == "aarch64" ]]; then
./configure --prefix=${PREFIX}\
            --host=aarch64-linux-gnu \
            --build=aarch64-linux-gnu \
            --enable-silent-rules \
            --enable-shared \
            --with-zlib \
            --with-jpeg \
            --disable-netcdf \
            --disable-hdf4-xdr \
            --disable-fortran || (cat config.log; exit 1)
else
./configure --prefix=${PREFIX}\
            --host=$HOST \
            --enable-silent-rules \
            --enable-shared \
            --with-zlib \
            --with-jpeg \
            --disable-netcdf \
            --disable-hdf4-xdr \
            --disable-fortran || (cat config.log; exit 1)
fi

# make sure that linux aarch64 configuration is defined ...
cp $RECIPE_DIR/hdfi.h hdf/src/hdfi.h

make
make install
# temporarily disabled due to segfault.
#make check

# Remove man pages.
rm -rf ${PREFIX}/share

# Avoid clashing names with netcdf.
mv ${PREFIX}/bin/ncdump ${PREFIX}/bin/h4_ncdump
mv ${PREFIX}/bin/ncgen ${PREFIX}/bin/h4_ncgen

# People usually Google these.
rm -rf ${PREFIX}/examples

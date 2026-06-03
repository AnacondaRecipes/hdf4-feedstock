set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%;%RECIPE_DIR%

mkdir build_dir
cd build_dir

:: Moving changes from patch here to avoid errors with patching on windows. 
:: Files have a different line ending and patch doesn't work well with that.
python -c "
content = open('hdf/src/hlimits.h').read()
content = content.replace('#   define MAX_FILE   32', '#   define MAX_FILE   4096')
open('hdf/src/hlimits.h', 'w').write(content)
"

:: Configure step.
cmake -G "%CMAKE_GENERATOR%" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_POLICY_VERSION_MINIMUM=3.5 ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D ZLIB_DIR=%LIBRARY_PREFIX% ^
      -D JPEG_DIR=%LIBRARY_PREFIX% ^
      -D HDF4_BUILD_FORTRAN=NO ^
      -D HDF4_ENABLE_NETCDF=NO ^
      -D BUILD_SHARED_LIBS:BOOL=ON ^
      -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Test.
ctest -C Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

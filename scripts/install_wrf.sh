#!/bin/bash
set -ex

# Necessary software
sudo yum groupinstall "Development Tools" -y
set +e
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
set -e

which gfortran
if [[ $? -ne 0 ]]; then
  echo "gfortran is not found"
  exit 1
fi
which cpp
if [[ $? -ne 0 ]]; then
  echo "cpp is not found"
  exit 1
fi
which gcc
if [[ $? -ne 0 ]]; then
  echo "gcc is not found"
  exit 1
fi

# Environment:
export wrf_basedir=~/wrf_benchmarks
export wrf_path=$wrf_basedir/WRF
export wps_path=$wrf_basedir/WPS
export libraries_path=$wrf_basedir/LIBRARIES

export CC=gcc
export CXX=g++
export FC=gfortran
export FCFLAGS=-m64
export F77=gfortran
export FFLAGS=-m64
export JASPERLIB=$libraries_path/grib2/lib
export JASPERINC=$libraries_path/grib2/include
export LDFLAGS=-L$libraries_path/grib2/lib
export CPPFLAGS=-I$libraries_path/grib2/include
export NETCDF=$libraries_path/netcdf
export PATH=$NETCDF/bin:$PATH

if [[ ! -d $wrf_basedir ]]; then
  echo "$wrf_basedir directory not found"
  exit 1
fi

mkdir $libraries_path
cd $libraries_path

wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/netcdf-4.1.3.tar.gz
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz
wget http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/zlib-1.2.7.tar.gz

# NETCDF
tar xzf netcdf-4.1.3.tar.gz
cd netcdf-4.1.3
./configure --prefix=$libraries_path/netcdf --disable-dap --disable-netcdf-4 --disable-shared
make
sudo make install >netcdf_install.log
grep -q "Congratulations! You have successfully installed netCDF!" netcdf_install.log
if [[ $? -ne 0 ]]; then
  echo "NETCDF is not installed successfully"
  exit 1
fi

cd ..

# ZLIB
tar xzf zlib-1.2.7.tar.gz
cd zlib-1.2.7
./configure --prefix=$libraries_path/grib2
make
sudo make install
cd ..

# LIBPNG
tar xzf libpng-1.2.50.tar.gz
cd libpng-1.2.50
./configure --prefix=$libraries_path/grib2
make
sudo make install
cd ..

# JASPER
tar xzvf jasper-1.900.1.tar.gz
cd jasper-1.900.1
./configure --prefix=$libraries_path/grib2
make
sudo make install
cd ..

cd ..

# WRF
wget https://github.com/wrf-model/WRF/archive/v4.2.1.tar.gz
tar xzf v4.2.1.tar.gz
rm v4.2.1.tar.gz
mv WRF-4.2.1 WRF
cd WRF
cp $wrf_basedir/config/configure.wrf .
./compile em_real >&log.compile
if [[ ! -s main/real.exe ]] || [[ ! -s main/wrf.exe ]] || [[ ! -s main/ndown.exe ]]; then
  echo "problem in WRF executable files"
  exit 1
fi
cd ..

# WPS
wget https://github.com/wrf-model/WPS/archive/v4.2.tar.gz
tar xzf v4.2.tar.gz
rm v4.2.tar.gz
mv WPS-4.2 WPS
cd WPS
./clean
cp $wrf_basedir/config/configure.wps .
./compile >&log.compile
if [[ ! -s geogrid/src/geogrid.exe ]] || [[ ! -s ungrib/src/ungrib.exe ]] || [[ ! -s metgrid/src/metgrid.exe ]]; then
  echo "problem in WPS executable files"
  exit 1
fi
cd ..
cd ..

export LD_LIBRARY_PATH=${HOME}/wrf_benchmarks/LIBRARIES/grib2/lib/:$LD_LIBRARY_PATH
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:'"$HOME"'/wrf_benchmarks/LIBRARIES/grib2/lib/' >>.bashrc

echo "WRF installation completed successfully"

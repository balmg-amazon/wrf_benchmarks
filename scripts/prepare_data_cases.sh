#!/bin/bash
set -ex

source ~/.bashrc

# Environment:
wrf_basedir=~/wrf_benchmarks
data_path=$wrf_basedir/DATA
cases_path=$wrf_basedir/cases
wrf_path=$wrf_basedir/WRF
wps_path=$wrf_basedir/WPS
scripts_path=$wrf_basedir/scripts

cases=(new_conus_12km new_conus_2.5km)

if [[ ! -d $wrf_basedir ]]; then
  echo "$wrf_basedir directory not found"
  exit 1
fi

mkdir $data_path
cd $data_path

# Download wps geog data
wget http://ec2-3-80-173-226.compute-1.amazonaws.com/efa/wrf/geog_high_res_mandatory.tar.gz
tar -xf geog_high_res_mandatory.tar.gz
if [[ ! -d "WPS_GEOG" ]]; then
  echo "WPS_GEOG directory not found"
  exit 1
fi
rm -rf geog_high_res_mandatory.tar.gz

# Download gfs data for new conus
wget http://ec2-3-80-173-226.compute-1.amazonaws.com/efa/wrf/new_conus.tar
tar -xf new_conus.tar
if [[ ! -d "new_conus" ]]; then
  echo "new_conus directory not found"
  exit 1
fi
rm -rf new_conus.tar

for case_name in "${cases[@]}"; do
  # Run WPS geogrid, ungrib and metgrid
  cd $wps_path
  ln -sf $cases_path/$case_name/namelist.wps .
  ls -sf $data_path/new_conus/* .
  ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
  ./link_grib.csh $data_path/new_conus/

  ./geogrid.exe >&log.geogrid
  ./ungrib.exe >&log.ungrib
  ./metgrid.exe >&log.metgrid

  # Run wrf real
  cd $wrf_path/run
  ln -sf $wps_path/met_em* .
  ln -sf $cases_path/$case_name/namelist.input .
  ./real.exe

  grep -q "SUCCESS" rsl.out.0000
  if [[ $? -ne 0 ]]; then
    echo "rsl.out.0000 in $WRF_PATH/run does not say 'SUCCESS'"
    echo "failed running real.exe"
    exit 1
  fi

  cp wrfbdy_d01 $cases_path/$case_name
  cp wrfinput_d01 $cases_path/$case_name

  cd $scripts_path
  # Clean WRF directory
  ./clear_wrf.sh

  # Clean WPS directory
  ./clear_wps.sh
done

echo "Data preparation completed successfully"

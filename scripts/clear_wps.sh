export wrf_basedir=~/wrf_benchmarks
export wps_path=$wrf_basedir/WPS

rm -rf $wps_path/FILE:*
rm -rf $wps_path/PFILE:*
rm -rf $wps_path/met_em*
rm -rf $wps_path/ungrib.log
rm -rf $wps_path/metgrid.log
rm -rf $wps_path/GRIBFILE.*
rm -rf $wps_path/namelist.wps
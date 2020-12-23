export wrf_basedir=~/wrf_benchmarks
export wrf_path=$wrf_basedir/WRF

rm -rf $wrf_path/run/wrfout*
rm -rf $wrf_path/run/wrfbdy*
rm -rf $wrf_path/run/wrfinput*
rm -rf $wrf_path/run/wrfrst*
rm -rf $wrf_path/run/rsl.*
rm -rf $wrf_path/run/met_em*
rm -rf $wrf_path/run/namelist.input
rm -rf $wrf_path/run/namelist.wps
# WRF Benchmarks

* cases: contains namelist.input and namelist.wps for each case
* scripts: contains install_wrf.sh and prepare_data_cases.sh 
* config: contains configure file used for WRF and WPS installation

## Installation
The WRF cluster creation depends on [Getting started with EFA and MPI](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa-start.html) steps:  
- In step 6 (Install your HPC application:  
Clone this repository into the node and execute **scripts/install_wrf.sh**.  
The script will create new directories inside wrf_benchmark (LIBRARIES, WRF, WPS).
    - should see `WRF installation completed successfully` in script output
- After step 8 (Launch EFA-enabled instances into a cluster placement group):  
execute **scripts/prepare_data_cases.sh** only on the master node.  
This script will create new directory inside wrf_benchmark (DATA)
    - should see `Data preparation completed successfully` in script output

## Usage
- hostfile must exist on master node contains private ip addresses on cluster nodes.
- run pytest test_wrf_benchmarks 
    - new json file will be saved to quickbuild
- send the json file to kibana.
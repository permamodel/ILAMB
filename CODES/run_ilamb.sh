#!/usr/bin/env bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=4:00:00
#PBS -N ILAMB.$PBS_O_LOGNAME
#
# ILAMB execution script adapted to run on `beach` through its queue
# manager. Submit this script with:
#
#   $ qsub run_ilamb.sh
# 

# Configure ILAMB dependencies and paths.
tools_dir=/home/csdms/tools
export NCARG_ROOT=$tools_dir/ncl
PATH=$NCARG_ROOT/bin:$tools_dir/ImageMagick/bin:$PATH
export ILAMB_ROOT=/scratch/pbs/ilamb

# Define model simulation type, CLM or CMIP5.
export MODELTYPE=CMIP5

# Define spatial resolution for diagnostics, 0.5x0.5, 1x1 or 2.5x2.5.
export SPATRES=0.5x0.5

# Define plot file type, i.e., eps, gif, pdf, png, ps.
export PLOTTYPE=png

cd $PBS_O_WORKDIR
echo $ILAMB_ROOT
date
ncl -n main_ncl_code.ncl
date

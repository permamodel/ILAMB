#!/usr/bin/env bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=4:00:00
#PBS -N ILAMB.$PBS_O_LOGNAME
#
# ILAMB execution script adapted for the `torque` queue
# manager. Submit this script with:
#
#   $ qsub run_ilamb.sh
# 

# ILAMB needs the ILAMB_ROOT var.
export ILAMB_ROOT=/scratch/pbs/ilamb
echo $ILAMB_ROOT

# NCL needs the NCARG_ROOT var, as well as the path to its executable.
export NCARG_ROOT=/home/csdms/tools/ncl
PATH=$NCARG_ROOT/bin:$PATH

# Define model simulation type, CLM or CMIP5.
export MODELTYPE=CMIP5

# Define spatial resolution for diagnostics, 0.5x0.5, 1x1 or 2.5x2.5.
export SPATRES=0.5x0.5

# Define plot file type, i.e., eps, gif, pdf, png, ps.
export PLOTTYPE=png

cd $PBS_O_WORKDIR
date
ncl -n main_ncl_code.ncl
date

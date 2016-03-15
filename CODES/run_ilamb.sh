#!/usr/bin/env bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=4:00:00
#PBS -N ILAMB.$PBS_O_LOGNAME
#
# ILAMB execution script adapted to run on `beach` through its queue
# manager. Submit this script with:
#
#   $ qsub /scratch/pbs/ilamb/CODES/run_ilamb.sh
#
# The output from the ILAMB run is saved to a tarball in the
# ILAMB_ROOT directory, `/scratch/pbs/ilamb`.
#
# Note that ILAMB will clobber the results of the previous run, which
# are stored in the static $ILAMB_ROOT/OUTPUT directory.

# Configure ILAMB dependencies and paths.
export ILAMB_ROOT=/scratch/pbs/ilamb
tools_dir=/home/csdms/tools
export NCARG_ROOT=$tools_dir/ncl
PATH=$NCARG_ROOT/bin:$tools_dir/ImageMagick/bin:$PATH
job_id=`basename $PBS_JOBID .beach.colorado.edu`

# Define model simulation type, CLM or CMIP5.
export MODELTYPE=CMIP5

# Define spatial resolution for diagnostics, 0.5x0.5, 1x1 or 2.5x2.5.
export SPATRES=0.5x0.5

# Define plot file type, i.e., eps, gif, pdf, png, ps.
export PLOTTYPE=png

cd $ILAMB_ROOT ; echo $ILAMB_ROOT
date
cd CODES
ncl -n main_ncl_code.ncl
cd $ILAMB_ROOT
tar zcf ILAMB.OUTPUT.$job_id.tar.gz -C $ILAMB_ROOT OUTPUT
date

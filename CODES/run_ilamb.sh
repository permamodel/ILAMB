#!/usr/bin/env bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=4:00:00
#PBS -N ILAMB
#
# ILAMB execution script adapted to run on `beach` through its queue
# manager. Submit this script with:
#
#   $ qsub /scratch/pbs/ilamb/CODES/run_ilamb.sh -m ae -M <email>
#
# The output from the ILAMB run is saved to a tarball in the
# ILAMB_ROOT directory, `/scratch/pbs/ilamb`.
#
# Note that ILAMB will clobber the results of the previous run, which
# are stored in the static $ILAMB_ROOT/OUTPUT directory.

# Define model simulation type, CLM or CMIP5.
export MODELTYPE=CMIP5

# Define spatial resolution for diagnostics, 0.5x0.5, 1x1 or 2.5x2.5.
export SPATRES=0.5x0.5

# Define plot file type: eps, pdf, png, or ps.
export PLOTTYPE=png

# Configure ILAMB paths and dependencies.
export ILAMB_ROOT=/scratch/pbs/ilamb
tools_dir=/home/csdms/tools
export NCARG_ROOT=$tools_dir/ncl
PATH=$NCARG_ROOT/bin:$tools_dir/ImageMagick/bin:$PATH
job_id=`basename $PBS_JOBID .beach.colorado.edu`

# Run ILAMB.
cd $ILAMB_ROOT ; echo $ILAMB_ROOT
cd CODES
echo "ILAMB start:" `date`
ncl -n main_ncl_code.ncl > $ILAMB_ROOT/OUTPUT/ILAMB.stdout
echo "ILAMB finish:" `date`

# Package results.
tarfile=ILAMB-$PBS_O_LOGNAME-$job_id.tar.gz
tar zcf $tarfile -C $ILAMB_ROOT OUTPUT
mv $tarfile $PBS_O_WORKDIR
rm $ILAMB_ROOT/OUTPUT/ILAMB.stdout

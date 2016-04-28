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
# The output from the ILAMB run is saved to a tarball in the user's
# working directory, along with PBS output and error logs.
#
# Note that ILAMB will clobber the results of the previous run, which
# are stored in the static $ILAMB_ROOT/OUTPUT directory.

# Define model simulation type, CLM or CMIP5.
export MODELTYPE=CMIP5

# Define spatial resolution for diagnostics, 0.5x0.5, 1x1 or 2.5x2.5.
export SPATRES=0.5x0.5

# Define plot file type: eps, pdf, png, or ps.
export PLOTTYPE=png

# Configure ILAMB deps NCL and ImageMagick.
tools_dir=/home/csdms/tools
export NCARG_ROOT=$tools_dir/ncl
PATH=$NCARG_ROOT/bin:$tools_dir/ImageMagick/bin:$PATH

# Configure ILAMB paths.
export ILAMB_ROOT=/scratch/pbs/ilamb
export ILAMB_CODESDIR=$ILAMB_ROOT/CODES
export ILAMB_DATADIR=$ILAMB_ROOT/DATA
export ILAMB_MODELSDIR=$ILAMB_ROOT/MODELS
export ILAMB_OUTPUTDIR=$ILAMB_ROOT/OUTPUT
stdout_file=$ILAMB_OUTPUTDIR/ILAMB.stdout
stderr_file=$ILAMB_OUTPUTDIR/ILAMB.stderr

# Run ILAMB.
cd $ILAMB_CODESDIR
echo "ILAMB start:" `date`
ncl -n main_ncl_code.ncl 1> $stdout_file 2> $stderr_file
echo "ILAMB finish:" `date`

# Package results.
job_id=`basename $PBS_JOBID .beach.colorado.edu`
tarfile=ILAMB-$PBS_O_LOGNAME-$job_id.tar.gz
tar zcf $tarfile -C $ILAMB_ROOT OUTPUT
mv $tarfile $PBS_O_WORKDIR

# Cleanup.
to_remove="$stdout_file $stderr_file \
    $ILAMB_CODESDIR/temp.data \
    $ILAMB_CODESDIR/tempfiles"
for item in $to_remove; do
    if [ -e $item ]; then
	rm -rf $item
    fi
done

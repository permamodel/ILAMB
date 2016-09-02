#!/usr/bin/env bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=2:00:00
#PBS -N ILAMB
#
# ILAMB execution script adapted to run on `beach` through its queue
# manager. Submit this script with:
#
#   $ qsub /home/csdms/tools/ILAMB/CODES/run_ilamb.sh -m ae -M <email>
#
# The output from the ILAMB run is saved to a tarball in the user's
# working directory, along with PBS output and error logs.

# Define model simulation type, CLM or CMIP5.
export MODELTYPE=CMIP5

# Define spatial resolution for diagnostics, 0.5x0.5, 1x1 or 2.5x2.5.
export SPATRES=0.5x0.5

# Define plot file type: eps, pdf, png, or ps.
export PLOTTYPE=png

# Define directories.
tools_dir=/home/csdms/tools
nas_dir=/nas/data/ILAMB
tmp_dir=/state/partition1

# Define output name.
job_id=`basename $PBS_JOBID .beach.colorado.edu`
output_name=ILAMB-$PBS_O_LOGNAME-$job_id

# Configure NCL and ImageMagick.
export NCARG_ROOT=$tools_dir/ncl
PATH=$NCARG_ROOT/bin:$tools_dir/ImageMagick/bin:$PATH

# Configure ILAMB paths.
export ILAMB_ROOT=$tools_dir/ILAMB
export ILAMB_CODESDIR=$ILAMB_ROOT/CODES
export ILAMB_DATADIR=$nas_dir/DATA
export ILAMB_MODELSDIR=$nas_dir/MODELS
export ILAMB_OUTPUTDIR=$tmp_dir/$output_name
export ILAMB_TMPDIR=$tmp_dir/tmp_$job_id
stdout_file=$ILAMB_OUTPUTDIR/ILAMB.stdout
stderr_file=$ILAMB_OUTPUTDIR/ILAMB.stderr

# Copy OUTPUT to tmp directory for job.
cp -R $nas_dir/OUTPUT $ILAMB_OUTPUTDIR

# Run ILAMB.
cd $ILAMB_CODESDIR
echo "ILAMB start:" `date`
ncl -n main_ncl_code.ncl 1> $stdout_file 2> $stderr_file
echo "ILAMB finish:" `date`

# Package results.
tarfile=$output_name.tar.gz
tar zcf $tarfile -C $tmp_dir $output_name
mv $tarfile $PBS_O_WORKDIR

# Cleanup.
to_remove="$stdout_file \
    $stderr_file \
    $ILAMB_OUTPUTDIR \
    $ILAMB_TMPDIR"
for item in $to_remove; do
    if [ -e $item ]; then
	rm -rf $item
    fi
done

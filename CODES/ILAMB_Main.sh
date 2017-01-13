#!/usr/bin/env bash
#
# An ILAMB execution script, useful for debugging.
#
# From this directory, run with:
#   $ bash ILAMB_Main.sh /path/to/ILAMB_PARA_SETUP 1>stdout 2>stderr &

if [ -z "$1" ]; then
    echo "Error: Must supply path to ILAMB parameter file"
    exit 1
fi

export ILAMB_CODESDIR=`pwd`
cd ..
export ILAMB_ROOT=`pwd`
cd $ILAMB_CODESDIR

# Allow a user to configure these directories.
export ILAMB_DATADIR=/nas/data/ILAMB/DATA
export ILAMB_MODELSDIR=/nas/data/ILAMB/MODELS
export ILAMB_OUTPUTDIR=/nas/data/ILAMB/tmp/OUTPUT
export ILAMB_TMPDIR=/nas/data/ILAMB/tmp
echo "ILAMB files and directories:"
echo "ILAMB_ROOT           $ILAMB_ROOT"
echo "ILAMB_CODESDIR       $ILAMB_CODESDIR"
echo "ILAMB_DATADIR        $ILAMB_DATADIR"
echo "ILAMB_MODELSDIR      $ILAMB_MODELSDIR"
echo "ILAMB_OUTPUTDIR      $ILAMB_OUTPUTDIR"
echo "ILAMB_TMPDIR         $ILAMB_TMPDIR"
echo "ILAMB parameter file $1"

# Configure NCL and ImageMagick. May need help from user.
tools_dir=/home/csdms/tools
export NCARG_ROOT=$tools_dir/ncl
PATH=$NCARG_ROOT/bin:$tools_dir/ImageMagick/bin:$PATH

## Define model simulation type, CLM, CMIP5, or MsTMIP.
export MODELTYPE=CMIP5

## Define spatial resolution for diagnostics, 0.5x0.5, 1x1 or 2.5x2.5.
export SPATRES=0.5x0.5

## Define plot file type, i.e., eps, gif, pdf, png, ps.
export PLOTTYPE=png

date
ncl -n main_ncl_code.ncl ParameterFile=\"$1\"  # http://www.ncl.ucar.edu/Applications/system.shtml
date

#!/usr/bin/env bash
#
# A simple ILAMB execution script, useful for debugging.
#
# From this directory, run with:
#   $ bash ILAMB_Main.sh 1>stdout 2>stderr

export ILAMB_CODESDIR=`pwd`
cd ..
export ILAMB_ROOT=`pwd`
cd $ILAMB_CODESDIR

# Allow a user to configure these directories.
export ILAMB_DATADIR=/home/ILAMB/DATA
export ILAMB_MODELSDIR=/home/ILAMB/MODELS
export ILAMB_OUTPUTDIR=/home/ILAMB/OUTPUT
export ILAMB_TMPDIR=/home/ILAMB/tmp

echo "ILAMB directories:"
echo "ILAMB_ROOT      $ILAMB_ROOT"
echo "ILAMB_CODESDIR  $ILAMB_CODESDIR"
echo "ILAMB_DATADIR   $ILAMB_DATADIR"
echo "ILAMB_MODELSDIR $ILAMB_MODELSDIR"
echo "ILAMB_OUTPUTDIR $ILAMB_OUTPUTDIR"
echo "ILAMB_TMPDIR    $ILAMB_TMPDIR"

## Define model simulation type, CLM or CMIP5.
export MODELTYPE=CMIP5

## Define spatial resolution for diagnostics, 0.5x0.5, 1x1 or 2.5x2.5.
export SPATRES=0.5x0.5

## Define plot file type, i.e., eps, gif, pdf, png, ps.
export PLOTTYPE=png

date
ncl -n main_ncl_code.ncl
date

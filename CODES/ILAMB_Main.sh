#!/usr/bin/env bash
#
# ILAMB execution script.
#
# Run with:
#   $ bash ILAMB_Main.sh 1>stdout 2>stderr

export ILAMB_CODESDIR=`pwd`
cd ..
export ILAMB_ROOT=`pwd`
cd $ILAMB_CODESDIR

# Allow a user to configure these directories.
export ILAMB_DATADIR=$HOME/DATA
export ILAMB_MODELSDIR=$HOME/MODELS
export ILAMB_OUTPUTDIR=$HOME/OUTPUT

echo "ILAMB directories:"
echo "ILAMB_ROOT      $ILAMB_ROOT"
echo "ILAMB_CODESDIR  $ILAMB_CODESDIR"
echo "ILAMB_DATADIR   $ILAMB_DATADIR"
echo "ILAMB_MODELSDIR $ILAMB_MODELSDIR"
echo "ILAMB_OUTPUTDIR $ILAMB_OUTPUTDIR"

## Define model simulation type, CLM or CMIP5.
export MODELTYPE=CMIP5

## Define spatial resolution for diagnostics, 0.5x0.5, 1x1 or 2.5x2.5.
export SPATRES=0.5x0.5

## Define plot file type, i.e., eps, gif, pdf, png, ps.
export PLOTTYPE=png

date
ncl -n main_ncl_code.ncl
date

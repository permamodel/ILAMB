#!/usr/bin/env bash
# ILAMB execution script.

export ILAMB_UNDER=`pwd`
cd ..
export ILAMB_ROOT=`pwd`

cd $ILAMB_UNDER

echo $ILAMB_ROOT

## Define model simulation type, CLM or CMIP5.
export MODELTYPE=CMIP5

## Define spatial resolution for diagnostics, 0.5x0.5, 1x1 or 2.5x2.5.
export SPATRES=0.5x0.5

## Define plot file type, i.e., eps, gif, pdf, png, ps.
export PLOTTYPE=pdf

date
ncl -n ./main_ncl_code.ncl
date

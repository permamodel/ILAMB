#!/bin/csh
##
#########################################################################
####     Main C-shell Code to Use ILAMB Diagnostic Package           ####
####     The purpose for this package, please read KEYWORD below     ####
####     For any question, please contact Dr. Randerson              ####
####     (jranders@uci.edu) or Mingquan Mu (mmu@uci.edu)             ####
#########################################################################
##

setenv ILAMB_UNDER `pwd`

cd ..

setenv ILAMB_ROOT `pwd`

cd $ILAMB_UNDER

echo $ILAMB_ROOT

## Define model simulation type, CLM or CMIP5.
setenv MODELTYPE CMIP5

## Define spatial resolution for diagnostics, 0.5x0.5, 1x1 or 2.5x2.5.
setenv SPATRES 0.5x0.5

## Define plot file type, i.e., eps, gif, pdf, png, ps.
setenv PLOTTYPE  eps

#if ( `hostname` =~ ys* || `hostname` =~ caldera* || `hostname` =~ geyser*) then
#  module rm ncl
#  module load ncl/6.3.0
#  module list
#endif

date
ncl -n ./main_ncl_code.ncl
date

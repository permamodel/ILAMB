#!/bin/csh
##
#########################################################################
####     Main C-shell Code to Use ILAMB Diagnostic Package           ####
####     The purpose for this package, please read KEYWORD below     ####
####     For any question, please contact Dr. Randerson              ####
####     (jranders@uci.edu) or Mingquan Mu (mmu@uci.edu)             ####
#########################################################################
##

if ( ! $?ILAMB_ROOT ) then
  setenv ILAMB_ROOT `pwd`/..
endif

if ( `hostname` =~ ys* || `hostname` =~ caldera* || `hostname` =~ geyser*) then
  module rm ncl
  module load ncl/6.2.0
  module list
endif

date
ncl -n ./convert1-twsa-grace.ncl
date

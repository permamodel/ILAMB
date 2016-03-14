;*************************************************************************************************
;**** main_ncl_code.ncl: Main Program to run CMIP5-to-OBS diagnostic package:                 ****
;**** annual mean, bias, rmse, phase score, taylor score, interannual variability score       ****
;**** and overall score. This code is developed by ILAMB Software Develop Group. For any      ****
;**** question, please contact Dr. Randerson (jranders@uci.edu) or Mingquan Mu (mmu@uci.edu). ****
;*************************************************************************************************

loadscript ("$ILAMB_ROOT/CODES/subroutines/library/library.ncl")

; ################################################################################################################################

begin

  ILAMBDir = getenv("ILAMB_ROOT")

  PlotType = getenv("PLOTTYPE")
  PlotType = str_lower(str_squeeze(PlotType))

  ; ++++ check if the sub directory tempfiles exists in INPUT, if not, create it ++++
  TempDir = ILAMBDir + "/CODES/tempfiles"

  system ("csh -c 'if (! -d "+TempDir+") then; mkdir "+TempDir+"; end if'")

; ++++++ Initializate all directories to empty +++++

  initialization ("all")

; ++++++ input control parameters for all selected variables +++++

  nvpa = 0
  nchk = 0

  VarNames = input_control_para (nvpa, nchk)

; +++++++++++ Run Global Variable diagnostics +++++++++++++

  do nv=0,dimsizes(VarNames)-1
     run_diagnostics (VarNames(nv))
  end do

; +++++++++++ Run Variable to Variable Relationships +++++++++++++

  if (nvpa.ge.1) then
     do nvp=1,nvpa
        run_func_pair (nvp)
     end do
     score_var2var(nvpa)
  end if

; +++++++++++ Run Time Series Comparisons +++++++++++++

  if (nchk.ge.1) then
     do nck=1,nchk
        run_point_check (nck)
     end do
  end if

; ++++++ Calculate Overall Scores for each Model +++++

  summary_all (VarNames, nvpa)

; ++++++ convert to PNG +++++

  convert_to_png (VarNames)

; ++++++ Generate HTML files to show diagnostic results +++++

  create_html (VarNames, nvpa, nchk)

; ++++++ Cleanup All Directories and Nonused Files +++++

  cleanup (VarNames, nvpa, "eps")

; ---------------------------------------------
; End for all diagnostics
; ---------------------------------------------
; ################################################################################################################################

end
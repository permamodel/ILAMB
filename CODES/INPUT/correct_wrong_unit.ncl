function correct_wrong_unit (VarName:string, ModelName:string)

; This function is used to correct wrong unit for a variable from a model.
;
; input and output variables and corresponding meaning:
;
;       VarName:   intput, name of a variable
;       ModelName: intput, name of a benchmark or model

begin

   results = 1.0

   ; +++++++++++++++ Retrieve unit for a Variable +++++++++++++++++

   ; ++++ burntarea in CCSM4 has wrong unit ++++
   if (str_lower(ModelName).eq."ccsm4" .and. str_lower(VarName).eq."burntarea") then
      results=1./12.
   end if

   ; ++++ burntarea in CESM1-BGC has wrong unit ++++
   if (str_lower(ModelName).eq."cesm1-bgc" .and. str_lower(VarName).eq."burntarea") then
      results=1./12.
   end if

   ; ++++ tws in ALMv1_CRUNCEP has wrong unit ++++
   if (str_lower(ModelName).eq."almv1_cruncep" .and. str_lower(VarName).eq. "twsa") then
      results=1.0/(3600.*24.)
   end if

   ; ++++ tws in CLM40cn has wrong unit ++++
   if (str_lower(ModelName).eq."clm40cn" .and. str_lower(VarName).eq. "twsa") then
      results=1.0/(3600.*24.)
   end if

   ; ++++ tws in CLM45bgc has wrong unit ++++
   if (str_lower(ModelName).eq."clm45bgc" .and. str_lower(VarName).eq. "twsa") then
      results=1.0/(3600.*24.)
   end if

   ; ++++ tws in CLM45bgc_CRUNCEP has wrong unit ++++
   if (str_lower(ModelName).eq."clm45bgc_cruncep" .and. str_lower(VarName).eq. "twsa") then
      results=1.0/(3600.*24.)
   end if

   ; ++++ tws in CLM45bgc_GSWP3 has wrong unit ++++
   if (str_lower(ModelName).eq."clm45bgc_gswp3" .and. str_lower(VarName).eq. "twsa") then
      results=1.0/(3600.*24.)
   end if

   ; ++++ tws in CLM45bgc_2degGSWP3 has wrong unit ++++
   if (str_lower(ModelName).eq."clm45bgc_2deggswp3" .and. str_lower(VarName).eq. "twsa") then
      results=1.0/(3600.*24.)
   end if

   ; ++++ burntarea in NorESM1-M has wrong unit ++++
   if (str_lower(ModelName).eq."noresm1-m" .and. str_lower(VarName).eq."burntarea") then
      results=1./12.
   end if

   ; ++++ tws in CLM5bgc01_2degGSWP3 has wrong unit ++++
   if (str_lower(ModelName).eq."clm5bgc01_2deggswp3" .and. str_lower(VarName).eq. "twsa") then
      results=1.0/(3600.*24.)
   end if

   ; ++++ burntarea in NorESM1-ME has wrong unit ++++
   if (str_lower(ModelName).eq."noresm1-me" .and. str_lower(VarName).eq."burntarea") then
      results=1./12.
   end if

   ; ++++ co2 in NOAA.GMD and MAUNA.LOA has wrong unit ++++
   if (any(str_lower(ModelName).eq.(/"mauna.loa", "noaa.gmd"/)) .and. str_lower(VarName).eq."co2") then
      results=1./1.0e6
   end if

   ; ++++ co2 in BNU-ESM has wrong unit ++++
   if (str_lower(ModelName).eq."bnu-esm" .and. str_lower(VarName).eq."co2") then
      results=28.966/44.
   end if

   ; ++++ co2 in CanESM2 has wrong unit ++++
   if (str_lower(ModelName).eq."canesm2" .and. str_lower(VarName).eq."co2") then
      results=1.0e-6
   end if

   ; ++++ co2 in CESM1-BGC has wrong unit ++++
   if (str_lower(ModelName).eq."cesm1-bgc" .and. str_lower(VarName).eq."co2") then
      results=1.0e-6
   end if

   ; ++++ co2 in cesm1_2bgc has wrong unit ++++
   if (str_lower(ModelName).eq."cesm1_2bgc" .and. str_lower(VarName).eq."co2") then
      results=1.0e-6
   end if

   ; ++++ co2 in MIROC-ESM has wrong unit ++++
   if (str_lower(ModelName).eq. "miroc-esm" .and. str_lower(VarName).eq."co2") then
      results=1.0e-6
   end if

   ; ++++ co2 in MPI-ESM-LR has wrong unit ++++
   if (str_lower(ModelName).eq."mpi-esm-lr" .and. str_lower(VarName).eq."co2") then
      results=1.0e-6
   end if

   ; ++++ co2 in MRI-ESM1 has wrong unit ++++
   if (str_lower(ModelName).eq."mri-esm1" .and. str_lower(VarName).eq."co2") then
      results=1.0e-6
   end if

   ; ++++ co2 in NorESM1-ME has wrong unit ++++
   if (str_lower(ModelName).eq."noresm1-me" .and. str_lower(VarName).eq."co2") then
      results=1.0e-6
   end if

   ; ++++ et in noresm1-m has the wrong unit ++++
   if (str_lower(ModelName).eq."noresm1-m" .and. VarName.eq."et") then
      results=0.001
   end if

   ; ++++ gpp in inmcm4 has all negative values over land ++++
   if (str_lower(ModelName).eq."inmcm4" .and. VarName.eq."gpp") then
      results=-1
   end if

   ; ++++ lai in inmcm4 has the wrong unit ++++
   if (str_lower(ModelName).eq."inmcm4" .and. VarName.eq."lai") then
      results=0.01
   end if

   ; ++++ nbp in GCP and HOFFMAN has wrong unit ++++
   if (any(str_lower(ModelName).eq.(/"gcp", "hoffman"/)) .and. str_lower(VarName).eq."nbp") then
      results=-1./(3600.*24.*365*1.0e-12)
   end if

   ; ++++ twsa in GRACE has wrong unit ++++
   ;if (str_lower(ModelName).eq."grace" .and. str_lower(VarName).eq."twsa") then
   ;   results=1./(3600.*24.*0.1)
   ;end if

   return (results)

end

function retrieve_unit (VarName:string, Source:string)

; This function is used to retrieve unit for a variable.
;
; input and output variables and corresponding meaning:
;
;       VarName: intput, name of a variable
;
;       results: output, coefficient of unit conversion from initial unit (results@Initial) to
;                        final unit (results@FinalTable for tables or results@FinalPlot for plots)   

begin

   VarName = str_squeeze(VarName)

   results            = 1.0
   results@Initial    = "N/A"
   results@FinalTable = "N/A"
   results@FinalPlots = "N/A"

   ; +++++++++++++++ Retrieve unit for a Variable +++++++++++++++++

   if (any(str_lower(VarName).eq.(/"albedo", "lai"/))) then
      results            = 1.0
      results@Initial    = "unitless"
      results@FinalTable = "unitless"
      results@FinalPlots = "unitless"
   end if

   if (any(str_lower(VarName).eq.(/"biomass", "soilc"/))) then
      results            = 1.0
      results@Initial    = "kgC/m2"
      results@FinalTable = "PgC"
      results@FinalPlots = "kgC/m2"
   end if

   if (str_lower(VarName).eq."burntarea") then
      results            = 12.
      results@Initial    = "%"
      results@FinalTable = "Mha/yr"
      results@FinalPlots = "%/yr"
   end if

   if (str_lower(VarName).eq."co2") then
      results            = 1.0e6
      results@Initial    = "mole fraction"
      results@FinalTable = "ppm"
      results@FinalPlots = "ppm"
   end if

   if (str_lower(VarName).eq."nbp") then
      results            = 3600.*24.*365*1.0e-12
      results@Initial    = "kgC/m2/s"
      results@FinalTable = "PgC/yr"
      results@FinalPlots = "PgC/yr"
   end if

   if (any(str_lower(VarName).eq.(/"gpp", "nee", "reco"/))) then
      results            = 3600.*24.*1000.
      results@Initial    = "kgC/m2/s"
      results@FinalTable = "gC/m2/day"
      results@FinalPlots = "gC/m2/day"
      if (any(str_upper(Source).eq.(/"FLUXNET-MTE", "GBAF"/))) then
         results@FinalTable = "PgC/yr"
      end if
   end if

   if (str_lower(VarName).eq."et") then
      results            = 3600.*24.
      results@Initial    = "kg/m2/s"
      results@FinalTable = "mm/day"
      results@FinalPlots = "mm/day"
   end if

   if (str_lower(VarName).eq."le") then
      results            = 1.0
      results@Initial    = "W/m2"
      results@FinalTable = "W/m2"
      results@FinalPlots = "W/m2"
   end if

   if (str_lower(VarName).eq."sh") then
      results            = 1.0
      results@Initial    = "W/m2"
      results@FinalTable = "W/m2"
      results@FinalPlots = "W/m2"
   end if

   if (str_lower(VarName).eq."pr") then
      results            = 3600.*24.
      results@Initial    = "kg/m2/s"
      results@FinalTable = "mm/day"
      results@FinalPlots = "mm/day"
   end if

   if (str_lower(VarName).eq."rhums") then
      results            = 1.
      results@Initial    = "%"
      results@FinalTable = "%"
      results@FinalPlots = "%"
   end if

   if (any(str_lower(VarName).eq.(/"rlds","rlns","rlus","rlut","rns","rnt","rsds","rsdt","rsns","rsus","rsut"/))) then
      results            = 1.0
      results@Initial    = "W/m2"
      results@FinalTable = "W/m2"
      results@FinalPlots = "W/m2"
   end if

   if (str_lower(VarName).eq."runoff") then
      results            = 3600.*24.
      results@Initial    = "kg/m2/s"
      results@FinalTable = "mm/day"
      results@FinalPlots = "mm/day"
   end if

   if (str_lower(VarName).eq."soilm") then
      results            = 0.1
      results@Initial    = "kg/m2"
      results@FinalTable = "cm"
      results@FinalPlots = "cm"
   end if

   if (str_lower(VarName).eq."twsa") then
      results            = 3600.*24.*0.1
      results@Initial    = "kg/m2/s"
      results@FinalTable = "cm"
      results@FinalPlots = "cm"
   end if

   if (str_lower(VarName).eq."twsa_per") then
      results            = 3600.*24.
      results@Initial    = "kg/m2/s"
      results@FinalTable = "mm/day"
      results@FinalPlots = "mm/day"
   end if

   if (str_lower(VarName).eq."twsc") then
      results            = 3600.*24.
      results@Initial    = "kg/m2/s"
      results@FinalTable = "mm/day"
      results@FinalPlots = "mm/day"
   end if

   if (any(str_lower(VarName).eq.(/"soilt", "sst", "tas", "ts", "tsl"/))) then
      results            = -273.14
      results@Initial    = "K"
      results@FinalTable = "C"
      results@FinalPlots = "C"
   end if

   return (results)

end

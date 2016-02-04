function retrieve_LongName (KeyWord:string)

; This function is used to retrieve longname for category, metric, etc, except variable and source 
; If you want to use your own, please define here.
;
; input and output variables and corresponding meaning:
;
;       KeyWord: intput, shortname of a variable or a metric

begin

  KeyWord = str_squeeze(KeyWord)

  results = str_upper(KeyWord)

  ; +++++++++++++++ LONGNAME OF A CATEGORY +++++++++++++++++

   if (str_lower(KeyWord).eq."carbon") then
      results = "Ecosystem and Carbon Cycle"
   end if

   if (str_lower(KeyWord).eq."hydrology") then
      results = "Hydrology Cycle"
   end if

   if (str_lower(KeyWord).eq."energy") then
      results = "Radiation and Energy Cycle"
   end if

   if (str_lower(KeyWord).eq."forcing") then
      results = "Forcings"
   end if

   if (str_lower(KeyWord).eq."other") then
      results = "Others"
   end if

  ; +++++++++++++++ THE LONGNAME OF A METRIC +++++++++++++++++

   if (str_lower(KeyWord).eq."annualmean") then
      results = "Annual Mean"
   end if

   if (str_lower(KeyWord).eq."bias") then
      results = "Bias"
   end if

   if (str_lower(KeyWord).eq."rmse") then
      results = "RMSE"
   end if

   if (str_lower(KeyWord).eq."globalbiasscore") then
      results = "Global Bias Score"
   end if

   if (str_lower(KeyWord).eq."phase") then
      results = "Phase Difference"
   end if

   if (str_lower(KeyWord).eq."phasescore") then
      results = "Seasonal Cycle Score"
   end if

   if (str_lower(KeyWord).eq."rmsescore") then
      results = "RMSE Score"
   end if

   if (str_lower(KeyWord).eq."taylorscore") then
      results = "Spatial Distribution Score"
   end if

   if (str_lower(KeyWord).eq."interannualscore") then
      results = "Interannual Variability Score"
   end if

   if (str_lower(KeyWord).eq."overallscore") then
      results = "Overall Score"
   end if

   if (str_lower(KeyWord).eq."summary") then
      results = "Summary"
   end if

   return (results)

end

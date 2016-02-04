function retrieve_weight (KeyWord1:string, KeyWord2:string)

; This function is used to retrieve weighting coefficient for a variable or metric, i.e., gpp, pr, tas, or rmsescore, etc.
;
; input and output variables and corresponding meaning:
;
;       KeyWord1: intput, shortname of a variable or a metric  
;       KeyWord2: intput, shortname of a source 

begin

  KeyWord1 = str_squeeze(KeyWord1)
  KeyWord2 = str_squeeze(KeyWord2)

  ; +++ Retrieve weighting for variable, source or a metric +++++++++++++++++

   if (any(str_lower(KeyWord1).eq.(/"globalbiasscore", "interannualscore", "phasescore", "rmsescore", "taylorscore"/))) then
      if (str_lower(KeyWord1).eq."rmsescore") then
         results = 2.0
      else
         results = 1.0
      end if
   else
      results = load_scoring_metrics (KeyWord1, KeyWord2)
   end if

   return (results)

end

function correct_wrong_others (VarName:string, ModelName:string)

; This function is used to correct wrong variable name for a benchmak or model.
;
;       input variables and corresponding meaning:
;
;       VarName:   input, name of a variable in benchmark or model
;       ModelName: input, name of a benchmark or model
;
;
;       output variables and corresponding meaning:
;
;       results:         output, "wrong" if the variable name is different with the systme.
;       results@VarName: output, the "corrected" variable name

begin

   results = "correct"

   ; +++++++++++++++ Retrieve unit for a Variable +++++++++++++++++

   ; ++++ tws in cesm1_2bgc has wrong name ++++
   if (str_lower(ModelName).eq."cesm1_2bgc" .and. str_lower(VarName).eq."twsc") then
      results@VarName = "tws"
      results         = "wrong"
   end if

   return (results)

end

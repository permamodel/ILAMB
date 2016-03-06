function retrieve_others (KeyWord:string, Func:string)

; This function is used to retrieve Function list for variable to variable relationship or Category list.
;
; input variables and corresponding Values:
;
;       KeyWord: input, variable to variable relationship, Category, or metrics
;       Func   : input, representative code of function for variable to variable relationship
;

begin

  KeyWord = str_squeeze(KeyWord)
  Func    = str_squeeze(Func)

  ; ++++++++++++++ List all metrics here ++++++++++++++++++
  Metrics = (/"annualmean","bias","rmse","phase","globalbiasscore","rmsescore","phasescore","taylorscore",\
              "interannualscore","overallscore"/)

  ; ++++++++++++++ List all categories here ++++++++++++++++++
  CatNames = (/"carbon","hydrology","energy","forcing","other"/)

  ; +++++++++++++++ Retrieve Relationship for Variable to Variable +++++++++++++++++

  ; Function Types of Relationships between 2 Variables
  FuncList = (/"correlation_line2line","correlation_line2map","correlation_map2map","function_bar","linear_ prediction"/)

  if (str_lower(KeyWord).eq."relationship") then
     i50 = stringtointeger(Func)
     if (.not.ismissing(i50)) then
        results = FuncList(i50-1)
     end if
     results@funclist = FuncList
     delete(i50)
  end if

  if (str_lower(str_lower(KeyWord)).eq."category") then
     results = dimsizes(CatNames)
     results@Category = CatNames
  end if

  if (str_lower(str_lower(KeyWord)).eq."metrics") then
     results = dimsizes(Metrics)
     results@Category = Metrics
  end if

  return(results)

end

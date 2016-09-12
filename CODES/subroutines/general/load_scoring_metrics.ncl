function load_scoring_metrics (VarName:string, Source:string)

begin

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; +++++++ read scoring metrics weight coeffients from the file: table_scoring_metrics.txt +++++++

; ++++ retrieve $ILAMB_ROOT ++++
DataDir = getenv("ILAMB_ROOT")

; ++++++++++ Find the file name ++++++++++
FileList = systemfunc ("ls " + getenv("ILAMB_CODESDIR") + "/INPUT/table_scoring_metrics.txt")

if (fileexists(FileList)) then

   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ++++ Read the file ++++
   data_1d = asciiread(FileList,-1,"string")

   print("                                                                       ")
   print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
   print("HERE ARE Weighting Coeffients for All Available Data: ")
   print(data_1d)

   ; ++++ Obtain Weighting Coefficients for All Variables and Sources ++++
   AllVarName    = str_get_field(data_1d(4:), 1, ",")
   AllSourceName = str_get_field(data_1d(4:), 2, ",")
   AllCertainty  = stringtofloat(str_get_field(data_1d(4:), 3, ","))
   AllScale      = stringtofloat(str_get_field(data_1d(4:), 4, ","))
   AllOverall    = stringtofloat(str_get_field(data_1d(4:), 5, ","))

   AllShortVarName   = str_get_field(AllVarName, 1, "(")
   AllLongVarName    = str_get_field(AllVarName, 2, "(")

   AllLongVarName    = str_sub_str(AllLongVarName, ")", "")

   AllShortVarName   = str_squeeze (AllShortVarName)
   AllLongVarName    = str_squeeze (AllLongVarName)

   AllShortSourceName = str_get_field(AllSourceName,  1, "(")
   AllLongSourceInfo  = str_get_field(AllSourceName,  2, "(")

   AllLongSourceInfo  = str_sub_str(AllLongSourceInfo, ")", "")

   AllLongSourceName  = str_get_field(AllLongSourceInfo,  1, "[")
   AllSourceReference = str_get_field(AllLongSourceInfo,  2, "[")

   AllSourceReference = str_sub_str(AllSourceReference, "]", "")

   AllShortSourceName = str_squeeze (AllShortSourceName)
   AllLongSourceName  = str_squeeze (AllLongSourceName)
   AllSourceReference = str_squeeze (AllSourceReference)

   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ++++ Retrieve the values for required VarName and Source ++++
   i50=ind(str_lower(VarName).eq.str_lower(AllShortVarName))

   if (dimsizes(i50).gt.1) then
      LongVarName0     = AllLongVarName(i50)
      ShortSourceName0 = AllShortSourceName(i50)
      LongSourceName0  = AllLongSourceName(i50)
      SourceReference0 = AllSourceReference(i50)
      Certainty0       = AllCertainty(i50)
      Scale0           = AllScale(i50)
      Overall0         = AllOverall(i50)

      j50             = ind(str_upper(Source).eq.str_upper(ShortSourceName0))

      if (.not.ismissing(j50)) then
         ShortVarName    = VarName
         LongVarName     = LongVarName0(j50)
         ShortSourceName = ShortSourceName0(j50)
         LongSourceName  = LongSourceName0(j50)
         SourceReference = SourceReference0(j50)
         Certainty       = Certainty0(j50)
         Scale           = Scale0(j50)
	 Overall         = Overall0(j50)
      else
         ShortVarName    = VarName
         LongVarName     = LongVarName0(0)
         ShortSourceName = ShortSourceName0
         LongSourceName  = LongSourceName0
         SourceReference = SourceReference0
         Certainty       = Certainty0
         Scale           = Scale0
         Overall         = Overall0(0)
      end if
      delete(j50)
   else
      if (.not.ismissing(i50)) then
         ShortVarName    = VarName
         LongVarName     = AllLongVarName(i50)
         ShortSourceName = AllShortSourceName(i50)
         LongSourceName  = AllLongSourceName(i50)
         SourceReference = AllSourceReference(i50)
         Certainty       = AllCertainty(i50)
         Scale           = AllScale(i50)
         Overall         = AllOverall(i50)
      else
         print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
         print("YOUR REQUIRED INFORMATION DOESN'T EXITS!! ITS VALUE IS SET TO 1!")
         ShortVarName    = VarName
         LongVarName     = "-999"
         ShortSourceName = "-999"
         LongSourceName  = "-999"
         SourceReference = "-999"
         Certainty       = 1.0
         Scale           = 1.0
         Overall         = 1.0
      end if
   end if

   delete(i50)
else
   print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
   print("THE FILE ../CODES/INPUT/table_scoring_metrics.txt DOESN'T EXITS!!")
   ShortVarName    = VarName
   LongVarName     = "-999"
   ShortSourceName = "-999"
   LongSourceName  = "-999"
   SourceReference = "-999"
   Certainty       = -999.0
   Scale           = -999.0
   Overall         = -999.0
end if

results                 = Overall
results@ShortVarName    = ShortVarName
results@LongVarName     = LongVarName
results@ShortSourceName = ShortSourceName
results@LongSourceName  = LongSourceName
results@SourceReference = SourceReference
results@Certainty       = Certainty
results@Scale           = Scale

return(results)

end

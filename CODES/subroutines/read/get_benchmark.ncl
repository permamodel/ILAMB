function get_benchmark (VarName:string, Source:string, BenchMarkRaw:string, StartYear:integer, EndYear:integer)

begin

; ##########################################################################################################

if (str_upper(BenchMarkRaw).eq."NO") then

   CorOtherInfo = correct_wrong_others (VarName, Source)

   if (str_lower(CorOtherInfo).eq."wrong") then
      CorrVarName = CorOtherInfo@VarName
   else
      CorrVarName = VarName
   end if

   ts = read_benchmark (CorrVarName, Source, StartYear, EndYear)

   UnitCoef = correct_wrong_unit (VarName, Source)

   ts = ts*UnitCoef
   delete(UnitCoef)

   ts_obs          = ts
   ts_obs@lat      = ts@lat
   ts_obs@lon      = ts@lon
   ts_obs@alt      = ts@alt
   ts_obs@LandFrac = ts@LandFrac
   ts_obs@GridArea = ts@GridArea
   ts_obs@SiteName = ts@SiteName
   ts_obs@LandType = ts@LandType

else

end if

return (ts_obs)

end

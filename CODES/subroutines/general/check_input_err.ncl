procedure check_input_err (cmipID:integer, varID:string, runID:integer, KeyWord:string, Source:string, \
                           BenchMarkRaw:string, ModelRaw:string, StartYear:integer, EndYear:integer)

begin

ModelNames = (/"bcc-csm1-1","CanESM2","CCSM4","GFDL-ESM2G","HadGEM2-CC","HadGEM2-ES","inmcm4","IPSL-CM5A-LR","IPSL-CM5A-MR",\
               "MIROC-ESM","MIROC-ESM-CHEM","MPI-ESM-LR","NorESM1-M"/)

NumRun     = (/3,5,6,1,3,4,1,5,1,3,1,3,3/)

VarNames   = (/"BurntArea","BioMass","NEE","GPP","Reco","LE","SH","Albedo"/)

i50 = ind(cmipID.eq.1)

if (dimsizes(i50).gt.1 .or. .not.ismissing(i50)) then
else
   print(" You haven't yet choosen any model for diagnostics!")
end if
delete(i50)

if (ismissing(varID)) then
   print("You haven't yet choosen any variable for diagnostics!")
end if

if (str_lower(KeyWord).eq."annualmean" .or. str_lower(KeyWord).eq."bias" .or. str_lower(KeyWord).eq."rmse" \
    .or. str_lower(KeyWord).eq."taylorscore" .or. str_lower(KeyWord).eq."phasescore" \
    .or. str_lower(KeyWord).eq."interannual" .or. str_lower(KeyWord).eq."all") then
else
   print("Please select ONE PROPER KEYWORD from listed below for diagnostics:")
   print("annualmean, bias, rmse, taylorscore, seasonal or interannual")
end if

; ---- Summary of the diagnostics selected ----

print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")

print("               ")
print("Here are summaries of your selections for ILAMB diagnostics")
print("               ")
print("CMIP5 models that you choose are : ")
do nv=0,dimsizes(cmipID)-1
   if (cmipID(nv).eq.1) then
      print(sprinti("%02i",nv+1) + ": " + ModelNames(nv))
   end if
end do
print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
print("               ")

print("No. of ensemble runs for each model that you choose are: ")
do nv=0,dimsizes(cmipID)-1
   if (cmipID(nv).eq.1) then
      if (runID(nv).eq.0 .or. runID(nv).ge.NumRun(nv)) then
         print(sprinti("%i",NumRun(nv)) + " for " + ModelNames(nv))
         runID(nv) = NumRun(nv)
      else
         print(sprinti("%i",runID(nv)) + " for " + ModelNames(nv))
      end if
   end if
end do

print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
print("               ")

   res=0
do ns=0, dimsizes(VarNames)-1
   status = isStrSubset(str_lower(varID), str_lower(VarNames(ns)))
   if (status) then
       res = 1
       break 
   end  if
      delete(status)
end do

if (res.eq.1) then
   print("The variable that you choose is : " + varID)
else
   print("Please choosea one correct variable from this list: ")
   StringListS=VarNames(0)
   do nv=1,dimsizes(VarNames)-1
      StringListS = StringListS + ", " + VarNames(nv)
   end do
   print(StringListS)
   delete(StringListS)
end if

print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
print("               ")

print("The benchmark source that you choose is : " + Source)

print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
print("               ")

if (str_lower(KeyWord).eq."all") then
   print("The diagnostic packages that you choose include: Annual Mean, Bias, RMSE, Spatial Taylor Score, Phase Score and Interannual Score")
else
   print("The diagnostic packages that you choose include: " + KeyWord + " only")
end if

if (str_lower(BenchMarkRaw).eq."yes") then
   print("You choose ORGINAL benchmark raw dataset!")
else
   print("You choose Preproccessed benchmark dataset!")
end if

if (str_lower(ModelRaw).eq."yes") then
   print("You choose ORGINAL model raw datasets!")
else
   print("You choose Preproccessed model datasets!")
end if

print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
print("               ")

print("The time period that you choose is : " + sprinti("%i",StartYear) + "-" + sprinti("%i",EndYear))

print("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
print("               ")

return (res)

end

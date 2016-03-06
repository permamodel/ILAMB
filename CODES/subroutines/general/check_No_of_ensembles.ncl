function check_No_of_ensembles(ModelNames:string, ModelRaw:string, modelID:string, expID:string, VarName:string)

begin

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; +++++++++++++++++ Retrieve Directory for ILAMB Root +++++++++++++++
ILAMBDir = getenv("ILAMB_ROOT")

nmod = dimsizes(ModelNames)

; ++++++++++++++++++++++++++++ Check Total No. of Ensembles for Each Model and Each Variable +++++++++++++++++++++++++
print("                                                                       ")
print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
print("Checking Total No. of Ensembles for Each Model and Variable: " + VarName)

NumRun = new((/nmod/), integer)

NumRun = 0

do nd=0, nmod-1

   if (str_lower(ModelRaw).eq."yes")
      ModelDir = ILAMBDir + "/MODELS" + "/original/" + ModelNames(nd) + "/" + VarName
   else
      ModelDir = ILAMBDir + "/MODELS" + "/derived/" + ModelNames(nd) + "/" + VarName
   end if

   FileList = systemfunc ("ls " + ModelDir + "/" + VarName + "_" \
                          + "*_" + ModelNames(nd) + "_" + expID + "_" + "*.nc")

   FileList = str_squeeze(FileList)

   if (dimsizes(FileList).gt.1) then

         res=0
      do nr=0, dimsizes(FileList)-1
         runID="r" + sprinti("%i",nr+1) + "i1p1"
         runID=str_squeeze(runID)
         status = isStrSubset(str_lower(FileList(nr)), str_lower(runID))
         if (status) then
            res = res + 1
         end  if
         delete(status)
      end do

      NumRun(nd) = res
      delete(res)

   else
      if (dimsizes(FileList).eq.1 .and. .not.ismissing(FileList)) then
         NumRun(nd) = 1
      end if
   end if
   delete(FileList)
end do

return(NumRun)

end

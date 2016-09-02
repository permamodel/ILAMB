function input_control_para (nvpa:integer, nchk:integer)

begin

;$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
; +++++++ read scoring metrics from the file: $ILAMB_ROOT/CODES/INPUT/table_scoring_metrics.txt +++++++

; ++++ retrieve $ILAMB_ROOT ++++
ILAMBDir = getenv("ILAMB_ROOT")

; ++++++++++ Find the file name ++++++++++
FileList = systemfunc ("ls " + ILAMBDir + "/CODES/INPUT/table_scoring_metrics.txt")

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
   AllSourceName = str_squeeze(str_get_field(data_1d(4:), 2, ","))
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

   AllScoreName  = str_split(data_1d(0)," ")
   AllScoreName  = str_squeeze(AllScoreName) + "Score"

   nscr          = dimsizes(AllScoreName)
   nsus          = dimsizes(AllSourceName)

   AllScoreID    = new((/nsus,nscr/), integer)

   do ijk = 1, nscr
      AllScoreMode  = str_get_field(data_1d(4:), ijk+5, ",")
      AllScoreMode  = str_squeeze(AllScoreMode)
      AllScoreMode  = str_lower(AllScoreMode)
      AllScoreID (:,ijk-1) = where(AllScoreMode.eq."no", 0, 1)
   end do

   delete(ijk)
   delete(data_1d)

end if

; ################################################################################################################################
; +++++++ input control parameters from the file: ILAMB_PARA_SETUP +++++++

; ++++++++++ read all input parameters from the control file ++++++++++
FileList = systemfunc ("ls " + ILAMBDir + "/CODES/INPUT/ILAMB_PARA_SETUP")

if (fileexists(FileList)) then

   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ++++ Obtain Models and # of ensembles ++++
   data_1d = asciiread(FileList,-1,"string")

   print("                                                                       ")
   print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
   print("HERE ARE YOUR INPUT CONTROL PARAMETER VALUES: ")
   print(data_1d)

   i50=ind(data_1d.eq."")

   if (dimsizes(i50).gt.1) then
      ii = i50(0) - 1
   else
      ii = i50 - 1
   end if
   
   ModelName0 = str_get_field(data_1d(2:ii), 1, "|")
   cmipID0    = stringtointeger(str_get_field(data_1d(2:ii), 2, "|"))
   runID0     = stringtointeger(str_get_field(data_1d(2:ii), 3, "|"))
   expID0     = str_get_field(data_1d(2:ii), 4, "|")

   nmod = ii -2 + 1

   imod = ind(cmipID0.gt.0)

   ModelNames = ModelName0(imod)
   cmipIDs    = cmipID0(imod)
   runIDs     = runID0(imod)
   expIDs     = expID0(imod)

   ModelNames = str_squeeze(ModelNames)
   expIDs     = str_squeeze(expIDs)

   delete(imod)
   delete(runID0)
   delete(cmipID0)
   delete(ModelName0)

   nmod = dimsizes(ModelNames)

   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ++++ Obtain Variables and KeyWords for Diagnostics ++++
   j50=ind(data_1d(ii+2:).eq."")

   if (dimsizes(j50).gt.1) then
      jj = j50(0) + ii + 1
   else
      jj = j50 + ii + 1
   end if

   nkey     = dimsizes(str_split(data_1d(ii+4),"|")) - 5

   VarNameList = str_get_field(data_1d(ii+5:jj), 1, "|")
   SourcesGV   = str_get_field(data_1d(ii+5:jj), 2, "|")
   Periods     = str_get_field(data_1d(ii+5:jj), 3, "|")
   SubRegS1    = str_get_field(data_1d(ii+5:jj), 4, "|")
   SubRegS2    = str_get_field(data_1d(ii+5:jj), 5, "|")

   StartYrS    = stringtointeger(str_get_field(Periods, 1, "-"))
   EndYrS      = stringtointeger(str_get_field(Periods, 2, "-"))

   VarNameList = str_squeeze(VarNameList)
   SourcesGV   = str_squeeze(SourcesGV)
   SubRegS1    = str_squeeze(SubRegS1)
   SubRegS2    = str_squeeze(SubRegS2)

   nvar        = dimsizes(VarNameList)

   KeyWordList = new((/nkey/), string)
   AllVarKeyID = new((/nvar,nkey/), integer)

   do nk = 0, nkey - 1
      KeyWordList(nk)   = str_get_field(data_1d(ii+4), nk+6, "|")
      AllVarKeyID(:,nk) = stringtointeger(str_get_field(data_1d(ii+5:jj), nk+6, "|"))
   end do

   KeyWordList = str_squeeze(KeyWordList)

   ij50        = ind(str_lower(KeyWordList).eq."phase")

   if (.not.ismissing(ij50)) then
       KeyWordList0 = KeyWordList
       VarKeyID0    = AllVarKeyID

       delete(AllVarKeyID)
       delete(KeyWordList)

       KeyWordList  = new((/nkey+1/), string)
       AllVarKeyID  = new((/nvar,nkey+1/), integer)

       KeyWordList(0:ij50)  = KeyWordList0(0:ij50)
       KeyWordList(ij50+1)  = "phase"
       KeyWordList(ij50+2:) = KeyWordList0(ij50+1:)

       AllVarKeyID(:,0:ij50)   = VarKeyID0(:,0:ij50)
       AllVarKeyID(:,ij50+1)   = VarKeyID0(:,ij50)
       AllVarKeyID(:,ij50+2:)  = VarKeyID0(:,ij50+1:)

       nkey        = nkey + 1

       delete(VarKeyID0)
       delete(KeyWordList0)
   end if

   ijk = ind (str_lower(KeyWordList).ne."annualmean" .and. str_lower(KeyWordList).ne."bias" \
             .and. str_lower(KeyWordList).ne."phase" .and. str_lower(KeyWordList).ne."rmse" )

   if (dimsizes(ijk).gt.1 .or. .not.ismissing(ijk)) then
      KeyWordList(ijk) = KeyWordList(ijk) + "Score"
   end if

   delete(ijk)

   ijk = ind (str_lower(KeyWordList).eq."phase")

   if (dimsizes(ijk).gt.1) then
      KeyWordList(ijk(1:)) = KeyWordList(ijk(1:)) + "Score"
   end if

   delete(ijk)

   ijk = ind (str_lower(KeyWordList).eq."rmse")

   if (dimsizes(ijk).gt.1) then
      KeyWordList(ijk(1:)) = KeyWordList(ijk(1:)) + "Score"
   end if

   delete(ijk)
   delete(ij50)

   KeyWordList1 = new((/nkey/), string)
   KeyWordList2 = new((/nkey/), string)
   VarKeyID1    = new((/nvar,nkey/), integer)
   VarKeyID2    = new((/nvar,nkey/), integer)

      nk1 = 0
      nk2 = 0
   do nk = 0, nkey - 1
      if (isStrSubset(str_lower(KeyWordList(nk)), "score")) then
         KeyWordList2(nk2) = KeyWordList(nk)
         VarKeyID2(:,nk2)  = AllVarKeyID(:,nk)
         nk2               = nk2 + 1
      else
         KeyWordList1(nk1) = KeyWordList(nk)
         VarKeyID1(:,nk1)  = AllVarKeyID(:,nk)
         nk1               = nk1 + 1
      end if
   end do

   KeyWordList(0:nk1-1)       = KeyWordList1(0:nk1-1)
   KeyWordList(nk1:nk1+nk2-1) = KeyWordList2(0:nk2-1)
   AllVarKeyID(:,0:nk1-1)        = VarKeyID1(:,0:nk1-1)
   AllVarKeyID(:,nk1:nk1+nk2-1)  = VarKeyID2(:,0:nk2-1)

   delete(VarKeyID1)
   delete(VarKeyID2)
   delete(KeyWordList1)
   delete(KeyWordList2)

   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ++++ Obtain information for variable to variable relationship ++++
   k50=ind(data_1d(jj+2:).eq."")

   if (dimsizes(k50).gt.1) then
      kk = k50(0) + jj + 1
   else
      kk = k50 + jj + 1
   end if

   nvarc     = dimsizes(str_split(data_1d(jj+3),"|")) - 2

   VarRowList0 = str_get_field(data_1d(jj+4:kk), 1, "|")

   nvarr = dimsizes(VarRowList0)

   VarColList = new((/nvarc/), string)
   VarPairID0 = new((/nvarr,nvarc/), integer)
   SourcesVV0 = new((/nvarr/), string)

   SourcesVV0 = str_get_field(data_1d(jj+4:kk), 2, "|")

   SourcesVV0 = str_squeeze(SourcesVV0) 

   do nk = 0, nvarc - 1
      VarColList(nk)  = str_get_field(data_1d(jj+3), nk+3, "|")
      VarPairID0(:,nk) = stringtointeger(str_get_field(data_1d(jj+4:kk), nk+3, "|"))
   end do

   ijk = ind (.not.ismissing(SourcesVV0) .and. SourcesVV0.ne."")

   SourcesVV  = SourcesVV0(ijk)
   VarPairID  = VarPairID0(ijk, :)
   VarRowList = VarRowList0(ijk)

   nvarr = dimsizes(VarRowList)

   delete(ijk)
   delete(SourcesVV0)
   delete(VarPairID0)
   delete(VarRowList0)

   SourcesVV  = str_squeeze(SourcesVV) 
   VarColList = str_squeeze(VarColList) 
   VarRowList = str_squeeze(VarRowList) 

   ; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   ; ++++ Obtain information for time series comparisons ++++
   l50=ind(data_1d(kk+2:).eq."")

   if (dimsizes(l50).gt.1) then
      ll = l50(0) + kk + 1
   else
      ll = l50 + kk + 1
   end if

   VarNameCheck = str_get_field(data_1d(kk+4:ll), 1, "|")
   SourcesCheck = str_get_field(data_1d(kk+4:ll), 2, "|")
   RegionsCheck = str_get_field(data_1d(kk+4:ll), 3, "|")

   VarNameCheck = str_squeeze(VarNameCheck)
   SourcesCheck = str_squeeze(SourcesCheck)
   RegionsCheck = str_squeeze(RegionsCheck)

   RegionsCheck = where(RegionsCheck.eq."", "Global", RegionsCheck)
   RegionsCheck = where(ismissing(RegionsCheck), "Global", RegionsCheck)

   ij51 = ind(VarNameCheck.ne."")
   ij52 = ind(SourcesCheck.ne."")
   nchk1 = dimsizes(ij51)
   nchk2 = dimsizes(ij52)

   if (nchk1.gt.1 .or. .not.ismissing(ij51)) then
      if (nchk2.gt.1 .or. .not.ismissing(ij52)) then
         if (nchk1.ge.nchk2) then
            nchk = nchk2
            VarNameCheck1 = VarNameCheck(ij52)
            SourcesCheck1 = SourcesCheck(ij52)
            RegionsCheck1 = RegionsCheck(ij52)
            delete(VarNameCheck)
            delete(SourcesCheck)
            delete(RegionsCheck)
            VarNameCheck = VarNameCheck1
            SourcesCheck = SourcesCheck1
            RegionsCheck = RegionsCheck1
            delete(VarNameCheck1)
            delete(SourcesCheck1)
            delete(RegionsCheck1)
         else
            nchk = nchk1
            VarNameCheck1 = VarNameCheck(ij51)
            SourcesCheck1 = SourcesCheck(ij51)
            RegionsCheck1 = RegionsCheck(ij51)
            delete(VarNameCheck)
            delete(SourcesCheck)
            delete(RegionsCheck)
            VarNameCheck = VarNameCheck1
            SourcesCheck = SourcesCheck1
            RegionsCheck = RegionsCheck1
            delete(VarNameCheck1)
            delete(SourcesCheck1)
            delete(RegionsCheck1)
         end if
      else
         nchk = 0
      end if
   else
      nchk = 0
   end if

   if (nchk.eq.1 .and. str_lower(str_squeeze(VarNameCheck)).eq."variables") then
      nchk = 0
   end if

   delete(ii)
   delete(jj)
   delete(kk)
   delete(ll)
   delete(i50)
   delete(j50)
   delete(k50)
   delete(l50)
   delete(ij51)
   delete(ij52)
   delete(data_1d)
else
   print("The File: " + FileList + " not exist!! Please create the control file first!")
   break
end if

ModelNames  =  str_squeeze(ModelNames)
VarNameList =  str_squeeze(VarNameList)
KeyWordList =  str_squeeze(KeyWordList)

; ################################################################################################################################
; ++++++ Create the INPUT Parameters for diagnostic packages +++++

; ++++++ Check KeyWords for dignostic package +++++
  VarNames0 = new((/100/), string)

   nv0 = 0
do nv = 0, nvar - 1

   if (str_lower(SourcesGV(nv)).eq."") then
      AllVarKeyID(nv,:) = 0
   end if

   ; ++++++ retrieve all benchmark sources for a given variable +++++
   if (str_lower(SourcesGV(nv)).eq."all") then
      Sources = check_AllDataSources (VarNameList(nv))
   else
      Sources = str_split(SourcesGV(nv),",")
   end if

   nsur = dimsizes(Sources)

   do ns = 1, dimsizes(Sources)
      if (nsur.gt.1) then
         Source = Sources(ns-1)
      else
         Source = Sources
      end if

      k50  = ind(str_lower(VarNameList(nv)).eq.str_lower(AllShortVarName) .and. str_upper(Source).eq.str_upper(AllShortSourceName))

      SourceScoreID = AllScoreID(k50,:)

      VarKeyID      = AllVarKeyID(nv,:)

      SourceRef     = AllSourceName(k50)

      delete(k50)

      do nsc = 0, nscr-1
         j50 = ind(str_lower(KeyWordList).eq.str_lower(AllScoreName(nsc)))
         VarKeyID(j50) = VarKeyID(j50)*SourceScoreID(nsc)
         delete(j50)
      end do

      delete(SourceScoreID)

      i50 = ind(VarKeyID.eq.1)

      if (dimsizes(i50).gt.1 .or. .not.ismissing(i50)) then

         VarNames0(nv0) = str_squeeze(VarNameList(nv))

         if (dimsizes(i50).gt.1) then

            keyword=str_lower(KeyWordList(i50(0)))
            do nk=1,dimsizes(i50)-1
               keyword=keyword + "," + str_lower(KeyWordList(i50(nk)))
            end do
         else
            keyword=str_lower(KeyWordList(i50))
         end if

         ; ++++++ Set parameters for global variable diagnostics +++++

         BenchMarkRaw = "no"
         ModelRaw     = "yes"
         VarObs       = VarNameList(nv)
         expID        = expIDs(0)
         SubReg1      = SubRegS1(nv)
         SubReg2      = SubRegS2(nv)

         DataInfo     = retrieve_DataInfo(VarNameList(nv), Source)
         VarModel     = DataInfo@VarModel
         modelID      = DataInfo@ModelComp
         Source       = Source
         StartYear    = DataInfo@StartYr
         EndYear      = DataInfo@EndYr
         delete(DataInfo)

         if (.not.ismissing(StartYrS(nv)) .and. .not.ismissing(EndYrS(nv))) then
            StartYr      = stringtointeger(StartYear)
            EndYr        = stringtointeger(EndYear)

            StartYrTmp   = (/StartYr, StartYrS(nv)/)
            EndYrTmp     = (/EndYr,   EndYrS(nv)/)
            StartYr0      = max(StartYrTmp)
            EndYr0        = min(EndYrTmp)
            StartYear = sprinti("%0.4i",StartYr0)
            EndYear   = sprinti("%0.4i",EndYr0)

            delete(StartYr)
            delete(StartYr0)
            delete(StartYrTmp)
            delete(EndYr)
            delete(EndYr0)
            delete(EndYrTmp)
         end if

         UnitInfo = retrieve_unit (VarObs, "")
         VarUnit  = UnitInfo@FinalPlots
         delete(UnitInfo)

         ; ++++++ Check # of Ensembles Availability ++++++
         runID  = runIDs
         cmipID = cmipIDs

         if (str_lower(ModelNames(0)).eq."meanmodel" .and. cmipID(0).ge.1) then
            nrun0 = check_No_of_ensembles (ModelNames(1:nmod-1), ModelRaw, modelID, expID, VarModel)
         else
            nrun0 = check_No_of_ensembles (ModelNames(0:nmod-1), ModelRaw, modelID, expID, VarModel)
         end if

         nrun  = new((/nmod/), integer)

         if (str_lower(ModelNames(0)).eq."meanmodel" .and. cmipID(0).ge.1) then
            nrun(0) = 1
            nrun(1:nmod-1) = nrun0
         else
            nrun(0:nmod-1) = nrun0
         end if

         cmipID = where(nrun.eq.0, 0, cmipID)

         runID  = where(runID.eq.0, nrun, runID)
         runID  = where(runID.gt.nrun, nrun, runID)
         runID  = where(nrun.eq.0, 0, runID)
         runID  = where(cmipID.eq.0, 0, runID)

         TableFileName = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_" + str_lower(VarObs) + "_" + str_upper(Source)

         header=new((/16/), string)

         header(0) = "+++++++++ Input control parameters to run diagnostic package for " + str_upper(VarObs) + " +++++++"
         header(1) = "         Variable Name: " + VarObs
         header(2) = "         Variable Unit: " + VarUnit
         header(3) = "Variable Name in Model: " + VarModel 
         header(4) = "    Component of Model: " + modelID 
         header(5) = "    Type of Simulation: " + expID
         header(6) = "             Benchmark: " + SourceRef
         header(7) = "         Benchmark Raw: " + str_lower(BenchMarkRaw)
         header(8) = "             Model Raw: " + str_lower(ModelRaw)
         header(9) = "            Start Year: " + StartYear
         header(10) = "              End Year: " + EndYear
         header(11) = " Multi Region Analysis: " + SubReg1
         header(12) = "Single Region Analysis: " + SubReg2
         header(13) = "         KeyWords List: " + keyword
         header(14) = "                                                                 "
         header(15) = "      Model Name" + "     cmipID  " + " runID "

         write_table(TableFileName, "w", [/header/], "%s")
         write_table(TableFileName,"a",[/ModelNames,cmipID,runID/], "%16s %8i %7i")

         ;print(asciiread(str_squeeze(TableFileName),-1,"string"))

         if (ns.eq.1) then
            nv0 = nv0 + 1
         end if

         delete(nrun)
         delete(nrun0)
         delete(runID)
         delete(cmipID)
         delete(header)
      end if
      delete(i50)
      delete(VarKeyID)
   end do
   delete(Sources)
end do

if (isdefined("ModelNames")) then
   delete(ModelNames)
end if

if (isdefined("StartYear")) then
   delete(StartYear)
end if

if (isdefined("EndYear")) then
   delete(EndYear)
end if

nvar=nv0

; ################################################################################################################################
; ++++++ Create the INPUT Parameters for Variable to Variable Relationships +++++

Vars1    = new((/nvarc/), string)
Vars2    = new((/nvarr/), string)
funID    = new((/nvarc/), integer)
Sources1 = new((/nvarc/), string)
Sources2 = new((/nvarr/), string)

   nk = 0
do n1 = 0, nvarc-1
do n2 = 0, nvarr-1
   if (VarPairID(n2,n1).gt.0) then
      funID(nk)    = VarPairID(n2,n1) 
      Vars1(nk)    = VarColList(n1)
      Vars2(nk)    = VarRowList(n2)
      Sources2(nk) = SourcesVV(n2)

      ijk          = ind(VarRowList.eq.Vars1(nk))
      if (.not.ismissing(ijk))
         Sources1(nk) = SourcesVV(ijk)
         nk = nk +1
      end if
   end if
end do
end do

nvpa = nk

;if (nvpa.eq.1 .and. str_lower(str_squeeze(Vars2)).eq."variables") then
;    nvpa = 0
;end if

; ++++++ input control parameters from a file: ../CODES/tempfiles/input_para_* +++++

do nk =0, nvpa-1

  ;++++ input the control parameters for the 1st variable ++++
  TableFileName1 = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_" + str_lower(Vars1(nk)) + "_" + str_upper(Sources1(nk))

  data_1d = asciiread(str_squeeze(TableFileName1),-1,"string")

  Var1          = str_squeeze(str_get_field(data_1d(1), 2, ":"))
  VarUnit1      = str_squeeze(str_get_field(data_1d(2), 2, ":"))
  VarModel1     = str_squeeze(str_get_field(data_1d(3), 2, ":"))
  modelID1      = str_squeeze(str_get_field(data_1d(4), 2, ":"))
  expID1        = str_squeeze(str_get_field(data_1d(5), 2, ":"))

  Source1Ref    = str_squeeze(str_get_field(data_1d(6), 2, ":"))
  BenchMarkRaw1 = str_squeeze(str_get_field(data_1d(7), 2, ":"))
  ModelRaw1     = str_squeeze(str_get_field(data_1d(8), 2, ":"))
  StartYear1    = stringtointeger(str_get_field(data_1d(9), 2, ":"))
  EndYear1      = stringtointeger(str_get_field(data_1d(10), 2, ":"))
  SubReg        = str_squeeze(str_get_field(data_1d(12), 2, ":"))
  ModelNames    = str_squeeze(str_get_field(data_1d(16:), 1, " "))
  cmipID1       = stringtointeger(str_get_field(data_1d(16:), 2, " "))
  runID1        = stringtointeger(str_get_field(data_1d(16:), 3, " "))

  delete(data_1d)

  nmod          = dimsizes(ModelNames)-1

  ;++++ input the control parameters for the 2nd variable ++++
  TableFileName2 = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_" + str_lower(Vars2(nk)) + "_" + str_upper(Sources2(nk))

  data_1d = asciiread(str_squeeze(TableFileName2),-1,"string")

  Var2          = str_squeeze(str_get_field(data_1d(1), 2, ":"))
  VarUnit2      = str_squeeze(str_get_field(data_1d(2), 2, ":"))
  VarModel2     = str_squeeze(str_get_field(data_1d(3), 2, ":"))
  modelID2      = str_squeeze(str_get_field(data_1d(4), 2, ":"))
  expID2        = str_squeeze(str_get_field(data_1d(5), 2, ":"))

  Source2Ref    = str_squeeze(str_get_field(data_1d(6), 2, ":"))
  BenchMarkRaw2 = str_squeeze(str_get_field(data_1d(7), 2, ":"))
  ModelRaw2     = str_squeeze(str_get_field(data_1d(8), 2, ":"))
  StartYear2    = stringtointeger(str_get_field(data_1d(9), 2, ":"))
  EndYear2      = stringtointeger(str_get_field(data_1d(10), 2, ":"))
  cmipID2       = stringtointeger(str_get_field(data_1d(16:), 2, " "))
  runID2        = stringtointeger(str_get_field(data_1d(16:), 3, " "))

  delete(data_1d)

  nmod          = dimsizes(ModelNames)-1

  StartYear = where(StartYear2.ge.StartYear1, StartYear2, StartYear1)
  EndYear   = where(EndYear2.ge.EndYear1, EndYear1, EndYear2)
  cmipID    = where(cmipID2.ge.cmipID1, cmipID1, cmipID2)
  runID     = where(runID2.ge.runID1, runID1, runID2)

  sFunc     = sprinti("%i",funID(nk))

  FuncType  = retrieve_others ("RelationShip", sFunc)
  delete(sFunc)
  
  Source1   = Sources1(nk)
  Source2   = Sources2(nk)

  ;++++ save the control parameters for relationships of pair of variables ++++
  header=new((/27/), string)

  header(0) = "+++++++++ Input control parameters to run diagnostic package for " + str_upper(Var1) + " +++++++"
  header(1) = "                                       "
  header(2) = "       Relationship: " + FuncType
  header(3) = "                                       "
  header(4) = "         Variable 1: " + Var1
  header(5) = "               Unit: " + VarUnit1
  header(6) = "      Name in Model: " + VarModel1 
  header(7) = " Component of Model: " + modelID1 
  header(8) = " Type of Simulation: " + expID1
  header(9) = "          Benchmark: " + Source1Ref
  header(10) = "     Benchmark Raw: " + str_lower(BenchMarkRaw1)
  header(11) = "         Model Raw: " + str_lower(ModelRaw1)
  header(12) = "                                       "
  header(13) = "        Variable 2: " + Var2
  header(14) = "              Unit: " + VarUnit2
  header(15) = "     Name in Model: " + VarModel2 
  header(16) = "Component of Model: " + modelID2
  header(17) = "Type of Simulation: " + expID2
  header(18) = "         Benchmark: " + Source2Ref
  header(19) = "     Benchmark Raw: " + str_lower(BenchMarkRaw2)
  header(20) = "         Model Raw: " + str_lower(ModelRaw2)
  header(21) = "                                       "
  header(22) = "        Start Year: " + sprinti("%0.4i",StartYear)
  header(23) = "          End Year: " + sprinti("%0.4i",EndYear)
  header(24) = "Subregion Analysis: " + SubReg
  header(25) = "                                       "
  header(26)= "      Model Name" + "      cmipID  " + " runID "

  TableFileName = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_pair" + sprinti("%0.2i",nk+1)

  write_table(TableFileName, "w", [/header/], "%s")
  write_table(TableFileName,"a",[/ModelNames,cmipID,runID/], "%16s %8i %7i")

  ;print(asciiread(str_squeeze(TableFileName),-1,"string"))

  delete(header)
end do

if (isdefined("ModelNames")) then
   delete(ModelNames)
end if

; ################################################################################################################################
; ++++++ Create the INPUT Parameters for Time Series Comparisons +++++

; ++++++ input control parameters from a file: ../CODES/tempfiles/input_para_* +++++

do nck =0, nchk-1

  ;++++ input the control parameters for variables ++++
  TableFileName = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_" + str_lower(VarNameCheck(nck)) + "_" + str_upper(SourcesCheck(nck))
  print(TableFileName)

  data_1d = asciiread(str_squeeze(TableFileName),-1,"string")

  Var          = str_squeeze(str_get_field(data_1d(1), 2, ":"))
  VarUnit      = str_squeeze(str_get_field(data_1d(2), 2, ":"))
  VarModel     = str_squeeze(str_get_field(data_1d(3), 2, ":"))
  modelID      = str_squeeze(str_get_field(data_1d(4), 2, ":"))
  expID        = str_squeeze(str_get_field(data_1d(5), 2, ":"))

  SourceRef    = str_squeeze(str_get_field(data_1d(6), 2, ":"))
  BenchMarkRaw = str_squeeze(str_get_field(data_1d(7), 2, ":"))
  ModelRaw     = str_squeeze(str_get_field(data_1d(8), 2, ":"))
  StartYear    = stringtointeger(str_get_field(data_1d(9), 2, ":"))
  EndYear      = stringtointeger(str_get_field(data_1d(10), 2, ":"))
  ModelNames   = str_squeeze(str_get_field(data_1d(16:), 1, " "))
  cmipID       = stringtointeger(str_get_field(data_1d(16:), 2, " "))
  runID        = stringtointeger(str_get_field(data_1d(16:), 3, " "))

  Var          = VarNameCheck(nck)
  Source       = SourcesCheck(nck)
  SubReg       = RegionsCheck(nck)

  nmod         = dimsizes(ModelNames)-1

  delete(data_1d)

  UnitInfo = retrieve_unit(Var, "")
  VarUnit  = UnitInfo@FinalPlots
  delete(UnitInfo)

  ;++++ save the control parameters for detail checked variables ++++
  header=new((/15/), string)

  header(0) = "+++++++++ Input control parameters to run point check for " + str_upper(Var) + " +++++++"
  header(1) = "         Variable Name: " + Var
  header(2) = "         Variable Unit: " + VarUnit
  header(3) = "Variable Name in Model: " + VarModel 
  header(4) = "    Component of Model: " + modelID 
  header(5) = "    Type of Simulation: " + expID
  header(6) = "             Benchmark: " + SourceRef
  header(7) = "         Benchmark Raw: " + str_lower(BenchMarkRaw)
  header(8) = "             Model Raw: " + str_lower(ModelRaw)
  header(9) = "            Start Year: " + sprinti("%0.4i",StartYear)
  header(10) = "              End Year: " + sprinti("%0.4i",EndYear)
  header(11) = "       Region Analysis: " + SubReg
  header(12) = "         KeyWords List: " + keyword
  header(13) = "                                                                                               "
  header(14) = "      Model Name" + "     cmipID  " + " runID "

  TableFileName = getenv("ILAMB_TMPDIR") + "/tempfiles/input_para_check" + sprinti("%0.2i",nck+1)

  write_table(TableFileName, "w", [/header/], "%s")
  write_table(TableFileName,"a",[/ModelNames,cmipID,runID/], "%16s %8i %7i")

  ;print(asciiread(str_squeeze(TableFileName),-1,"string"))

  delete(header)
end do

if (nvar.eq.0) then
   print("WRONG!! You Don't Choose any VARIABLE for diagnostics!")
   print("Please check ILAMB_PARA_SETUP and modify your input.")
   break
else
   return(VarNames0(0:nvar-1))
end if

end

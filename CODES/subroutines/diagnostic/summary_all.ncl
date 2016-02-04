procedure summary_all (VarNames:string, nvpa:integer)

begin

ILAMBDir = getenv("ILAMB_ROOT")

nvar=dimsizes(VarNames)

CatInfo       = retrieve_others ("Category", "")
ShortCatNames = CatInfo@Category

ncat = dimsizes(ShortCatNames)

;+++++++++++++++++++++++ Collect infor for Categories ++++++++++++++++++++++++++++++++++++++
LongCatNames  = new((/ncat/), string)      ; save long names for catefories
LongVarNames  = new((/nvar/), string)      ; save long names for catefories
CatsID        = new((/ncat,nvar/), integer); separate variables for each category
CatNumb       = new((/ncat/), integer)          ; save total numbers of variables for each category
wts           = new((/ncat/), float)       ; save weightings for categories
wgts          = new((/nvar/), float)       ; save weightings for variables

wts      = 0.
wgts     = 0.

CatNumb  = 0
CatsID   = -999

do nc=0,ncat-1
   LongCatNames(nc) = retrieve_LongName (ShortCatNames(nc))
end do

do nv = 0, nvar-1
   do nc = 0, ncat-1
      DataInfo = retrieve_DataInfo (VarNames(nv), "")
      Category = DataInfo@Category
      delete(DataInfo)
      if (str_lower(Category).eq.str_lower(ShortCatNames(nc))) then
         CatsID(nc,nv) = nv
         CatNumb(nc)   = CatNumb(nc) + 1
      end if
   end do
end do

;############################## Deal with Overall Score for Global Variables ##############################
; +++++++ read scores from file saved for each variable +++++++++++
if (nvar.gt.1) then
   keywords=new((/nvar/), string)
   numbs=new((/nvar/), float)
   score=new((/nvar, 100/), float)
   numbs=0.
   score=-999
   score@_FillValue = -999
   do nv=0,nvar-1
      FileList1 = systemfunc ("ls " + ILAMBDir + "/OUTPUT/" + str_lower(VarNames(nv)) + "/summary/summary" + \
                             "_" + str_lower(VarNames(nv)) + "_" + "CMIP5.vs.*.txt")
     
      if (dimsizes(FileList1).eq.1) then
         FileList = FileList1
      else
         ndim=dimsizes(FileList1)
         ijks=new((/ndim/), integer)
         do i=0,ndim-1
            ijks(i)=dimsizes(stringtocharacter(FileList1(i)))
         end do
         i50=maxind(ijks)
         FileList = FileList1(i50)
         delete(i50)
         delete(ijks)
      end if

      if (.not.ismissing(FileList)) then
         data_1d = asciiread(FileList,-1,"string")
         nkey     = dimsizes(str_split(data_1d(6)," "))
         nmod     = dimsizes(data_1d(10:))
         keywords(nv) = str_get_field(data_1d(6), nkey, " ")
         numbs(nv) = stringtofloat(str_get_field(data_1d(7), nkey, " "))
         Models = str_get_field(data_1d(10:), 1, " ")
         score0 = stringtofloat(str_get_field(data_1d(10:), nkey, " "))
         score(nv,0:nmod-1)=score0

         score0@_FillValue = -999

         DataInfo = retrieve_DataInfo (VarNames(nv), "")
         Category = DataInfo@Category
         j50 = ind(str_lower(ShortCatNames).eq.str_lower(Category))
         if (.not.ismissing(j50) .and. any(.not.ismissing(score0))) then
            Coef             = retrieve_weight (VarNames(nv), "-999")
            wts(j50)         = wts(j50) + Coef
            wgts(nv)         = Coef
            LongVarNames(nv) = Coef@LongVarName
         end if
         delete(j50)
         delete(score0)
         delete(data_1d)

      else

         print("File for " + VarNames(nv) + " OverAllScore not exist!! Please calculate first!")
         break
      end if
      delete(FileList1)
   end do
   scores=new((/nmod/), float)
   do nd=0,nmod-1
      ;scores(nd)=dim_sum(score(:,nd)*numbs)/sum(numbs)
      scores(nd)=dim_sum(score(:,nd)*wgts)/sum(wgts)
   end do
   delete(score)

else

   FileList1 = systemfunc ("ls " + ILAMBDir + "/OUTPUT/" + str_lower(VarNames) + "/summary/summary" + \
                          "_" + str_lower(VarNames) + "_" + "CMIP5.vs.*.txt")
     
   if (dimsizes(FileList1).eq.1) then
      FileList = FileList1
   else
      ndim=dimsizes(FileList1)
      ijks=new((/ndim/), integer)
      do i=0,ndim-1
         ijks(i)=dimsizes(stringtocharacter(FileList1(i)))
      end do
      i50=maxind(ijks)
      FileList = FileList1(i50)
      delete(i50)
      delete(ijks)
   end if

   if (.not.ismissing(FileList)) then
      data_1d = asciiread(FileList,-1,"string")
      nkey     = dimsizes(str_split(data_1d(6)," "))
      nmod     = dimsizes(data_1d(10:))
      numbs = stringtofloat(str_get_field(data_1d(7), nkey, " "))
      Models = str_get_field(data_1d(10:), 1, " ")
      scores = stringtofloat(str_get_field(data_1d(10:), nkey, " "))

      scores@_FillValue = -999

      DataInfo = retrieve_DataInfo (VarNames, "")
      Category = DataInfo@Category
      delete(DataInfo)
      j50 = ind(str_lower(ShortCatNames).eq.str_lower(Category))
      if (.not.ismissing(j50) .and. any(.not.ismissing(scores))) then
         Coef         = retrieve_weight (VarNames, "-999")
         wts(j50)     = wts(j50) + Coef
         wgts         = Coef
         LongVarNames = Coef@LongVarName
         delete(Coef)
      end if

      delete(j50)
      delete(data_1d)

   else
      print("File for " + VarNames(nv) + " OverAllScore not exist!! Please calculate first!")
      break
   end if
   delete(FileList1)
end if

if (nvar.gt.1) then
   Vars=VarNames(0)
   do nv=1,nvar-1
      Vars=Vars + "+" + VarNames(nv)
   end do
else
   Vars=VarNames
end if

scores@_FillValue=-999

scoreGV=new((/nmod+1/), float) 
scoreGV(0)=-999
scoreGV(1:nmod)=scores

scoreGV@_FillValue=-999

ModelNameList=new((/nmod+1/), string) 
ModelNameList(0)="Benchmark"
ModelNameList(1:nmod)=Models

delete(scores)
delete(Models)

;----------- Save Overall Score for Global Variables -----------------------------------------
header=new((/3/), string)

header(0) = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
header(1) = "Variable Name: " + str_upper(Vars)
header(2) = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

TableFileName = ILAMBDir + "/OUTPUT/summary/overallscore_GlobalVariables.txt"
print(TableFileName)

write_table(TableFileName, "w", [/header/], "%s")
write_table(TableFileName,"a",[/ModelNameList(1:nmod),scoreGV(1:nmod)/], "%16s %10.2f")

print("Summary of Selected All Diagnostics")
print(asciiread(TableFileName,-1,"string"))
delete(header)

; ++++++++++ Create a txt file and save Weightings for categories +++++++++++

;wts=wts*100/sum(wts)

TableFileName = ILAMBDir + "/OUTPUT/summary/weights_category.txt"

print(TableFileName)

header = "Contributions from categories "

write_table(TableFileName, "w", [/header/], "%s")
write_table(TableFileName,"a",[/"category", "Weights"/], "%34s %16s")
write_table(TableFileName,"a",[/LongCatNames+":",wts/], "%34s %16.0f")

;print(asciiread(TableFileName,-1,"string"))
delete(header)

; ++++++++++ Create a txt file and save Weighting for each variable +++++++++++

;wgts=wgts*100/sum(wgts)

TableFileName = ILAMBDir + "/OUTPUT/summary/weights_allvariables.txt"

print(TableFileName)

header = "++++++++++++ Contribution from each variable ++++++++++++"

write_table(TableFileName, "w", [/header/], "%s")
write_table(TableFileName,"a",[/"Variable", "Weights"/], "%40s %16s")
do nc =0, ncat-1
   if (CatNumb(nc).gt.0) then
      j50 = ind(CatsID(nc,:).ne.-999)
      if (dimsizes(j50).gt.1 .or. .not.ismissing(j50))
         tempstrings = LongVarNames(j50)
         tempdata    = wgts(j50)
         ip5         = dim_pqsort(tempdata, -1) 
         write_table(TableFileName,"a",[/"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++"/], "%s")
         write_table(TableFileName,"a",[/LongCatNames(nc)+":",sum(tempdata(ip5))/], "%40s %16.0f")
         write_table(TableFileName,"a",[/tempstrings(ip5)+":",tempdata(ip5)/], "%40s %16.0f")
         delete(ip5)
         delete(tempdata)
         delete(tempstrings)
      end if
      delete(j50)
   end if
end do

;print(asciiread(TableFileName,-1,"string"))
delete(header)

;----------- Draw Overall Score for Global Variables -----------------------------------------

PlotFileName = "../OUTPUT/summary/overallscore_GlobalVariables"
print(PlotFileName)

titles       = "Overallscore for Global Variables"

Draw_Score (PlotFileName, scoreGV, ModelNameList, titles)
delete(titles)

;############################## Calculate Overall Score for Variable to Variable ##############################

;++++++++++++++++++++++++ read Variable to Variable Score from each file +++++++++++++++++++++++++++

scoreVV=new((/nmod+1/), float) 
scoreVV(0)=-999

if (nvpa .ge.1) then

   scores=new((/nvpa, nmod/), float)
   wgtsVV=new((/nvpa/), float)

   Var1NameList=new((/nvpa/), string)
   Var2NameList=new((/nvpa/), string)

   scores=-999
   wgtsVV=-999

   wtVV = 0.0

   do nvp =1, nvpa

      TableFileName = ILAMBDir + "/OUTPUT/v2vscore/v2vscore_pair" + sprinti("%0.2i",nvp) + ".txt"
      print(TableFileName)

      data_1d = asciiread(TableFileName,-1,"string")

      Var1Names       = str_get_field(data_1d(1), 1, " ")
      Var2Names       = str_get_field(data_1d(1), 2, " ")

      scoret = stringtofloat(str_get_field(data_1d(2:), 2, " "))

      Var1Names       = str_get_field(data_1d(1), 1, " ")
      Var2Names       = str_get_field(data_1d(1), 2, " ")

      Var1Name        = str_get_field(Var1Names, 1, "(")
      Source1Name     = str_get_field(Var1Names, 2, "(")

      Var2Name        = str_get_field(Var2Names, 1, "(")
      Source2Name     = str_get_field(Var2Names, 2, "(")

      Source1Name     = str_sub_str(Source1Name, ")", "")
      Source2Name     = str_sub_str(Source2Name, ")", "")

      Var1Name        = str_squeeze (Var1Name)
      Var2Name        = str_squeeze (Var2Name)

      Source1Name     = str_squeeze (Source1Name)
      Source2Name     = str_squeeze (Source2Name)

      Var1NameList (nvp-1) = str_squeeze(Var1Names)
      Var2NameList (nvp-1) = str_squeeze(Var2Names)

      Coef1           =  retrieve_weight (Var1Name, Source1Name)
      Coef2           =  retrieve_weight (Var2Name, Source2Name)

      Coef            = Coef1 + Coef2

      wtVV            = wtVV + Coef
   
      scores(nvp-1,:) = scoret*Coef

      wgtsVV (nvp-1)  = Coef

      delete(Coef)
      delete(Coef1)
      delete(Coef2)
      delete(scoret)
   end do

   scores = scores/wtVV

   scores@_FillValue = -999

   scoreVV(1:nmod) = dim_sum_n(scores, 0)

   scoreVV@_FillValue=-999

   delete(scores)

   ;----------- Save Overall Score for Variable to Variable -----------------------------------------
   header=new((/3/), string)

   header(0) = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   header(1) = "Overall Score: Variable to Variable"
   header(2) = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

   TableFileName = ILAMBDir + "/OUTPUT/summary/overallscore_Variable2Variable.txt"
   print(TableFileName)

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/ModelNameList(1:nmod),scoreVV(1:nmod)/], "%16s %10.2f")

   print("Summary of All Variable to Variable Diagnostics")
   print(asciiread(TableFileName,-1,"string"))
   delete(header)

   ; ++++++++++ Create a txt file and save Weighting for each variable to variable pair +++++++++++

   ;wgtsVV=wgtsVV*100/sum(wgtsVV)
   Var2VarList = Var1NameList + " with " + Var2NameList

   TableFileName = ILAMBDir + "/OUTPUT/summary/weights_allvar2var.txt"

   print(TableFileName)

   j50 = dim_pqsort(wgtsVV, -1)

   header = "+++++++++++ Contribution from each variable to variable pair ++++++++++"

   write_table(TableFileName, "w", [/header/], "%s")
   write_table(TableFileName,"a",[/"Var2Var Pair", "Weights"/], "%54s %16s")
   write_table(TableFileName,"a",[/Var2VarList(j50)+":",wgtsVV(j50)/], "%54s %16.0f")

   ;print(asciiread(TableFileName,-1,"string"))
   delete(header)
   delete(j50)

   ;----------- Draw Overall Score for Variable to Variable -----------------------------------------

   PlotFileName = "../OUTPUT/summary/overallscore_Variable2Variable"
   print(PlotFileName)

   titles       = "Overallscore for Variable to Variable"

   Draw_Score (PlotFileName, scoreVV, ModelNameList, titles)

   delete(titles)

end if

;############################## Deal with Overall Score for All Diagnostics ##############################

scores=new((/nmod+1,2/), float)

scores(:,0) = scoreGV
scores(:,1) = scoreVV

scores@_FillValue=-999

scoreAll = dim_avg(scores)

delete(scores)

;----------- Save Overall Score for All Diagnostics -----------------------------------------
header=new((/3/), string)

header(0) = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
header(1) = "Overall Score: All Diagnostics"
header(2) = "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

TableFileName = ILAMBDir + "/OUTPUT/summary/overallscore_all.txt"
print(TableFileName)

write_table(TableFileName, "w", [/header/], "%s")
write_table(TableFileName,"a",[/ModelNameList(1:nmod),scoreAll(1:nmod)/], "%16s %10.2f")

print("Summary of All Diagnostics")
print(asciiread(TableFileName,-1,"string"))
delete(header)

;----------- Draw Overall Score for All Diagnostics -----------------------------------------

PlotFileName = "../OUTPUT/summary/overallscore_all"
print(PlotFileName)

titles       = "Overallscore for All Diagnostics"

Draw_Score (PlotFileName, scoreAll, ModelNameList, titles)

end

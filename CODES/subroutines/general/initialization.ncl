procedure initialization (FileType:string)

begin

ILAMBDir = getenv("ILAMB_ROOT")

PlotType = getenv("PLOTTYPE")
PlotType = str_lower(str_squeeze(PlotType))

SpecDirs = (/".sh","readme","relationships","summary","v2vscore","www"/)

; retrieve Function Types of Relationships between 2 Variables

FuncType = retrieve_others ("RelationShip", "4")

FuncList = FuncType@funclist

nfun = dimsizes(FuncList)

delete(FuncType)

print("                                                                       ")
print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
print("Clean Up Requested Directories and Files")

DataDir = getenv("ILAMB_OUTPUTDIR") + "/"

AllDirList = systemfunc ("ls " + DataDir)

AllDirList = str_squeeze(AllDirList)

do ns = 0, dimsizes(SpecDirs)-1
   i50 = str_match_ind_ic(AllDirList, SpecDirs(ns))
   if (dimsizes(i50).gt.1 .or. .not.ismissing(i50)) then
       AllDirList(i50) = "-999"
   end if
   delete(i50)
end do

i50 = ind(AllDirList .ne. "-999")

VarDirList = AllDirList(i50)

nvar     = dimsizes(VarDirList)

if (dimsizes(VarDirList).gt.1) then
   VarNames = new((/nvar/), string)
   do nv = 0, nvar-1
      Source0     = str_split(VarDirList(nv),"/")
      nlast       = dimsizes(Source0)
      VarNames(nv) = Source0(nlast-1)
      delete(Source0)
   end do
else
   Source0        = str_split(VarDirList,"/")
   nlast          = dimsizes(Source0)
   VarNames        = Source0(nlast-1)
   delete(Source0)
end if

delete(i50)
delete(AllDirList)
delete(VarDirList)

; +++++++++ Delete eps, png or txt files bases on the definition of "FileType" ++++++++++

if (str_lower(FileType).eq."all") then

   TempDir = getenv("ILAMB_TMPDIR") + "/tempfiles"

   system ("/bin/rm -f " + TempDir + "/*")

   if (nvar.gt.1) then
      do nv=0,nvar-1
         KeyWords = systemfunc ("ls " + getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)))
         if (dimsizes(KeyWords).gt.1) then
            do nk=0,dimsizes(KeyWords)-1
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords(nk)
               system ("/bin/rm -f " + DataDirPlot + "/*.*")
               system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
               system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end do
         else
            if (.not.ismissing(KeyWords)) then
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords
               system ("/bin/rm -f " + DataDirPlot + "/*.*")
               system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
               system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end if
         end if
         delete(KeyWords)
      end do
   else
      if (.not.ismissing(VarNames)) then
         KeyWords = systemfunc ("ls " + getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames))
         if (dimsizes(KeyWords).gt.1) then
            do nk=0,dimsizes(KeyWords)-1
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/" + KeyWords(nk)
               system ("/bin/rm -f " + DataDirPlot + "/*.*")
               system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
               system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end do
         else
            if (.not.ismissing(KeyWords)) then
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/" + KeyWords
               system ("/bin/rm -f " + DataDirPlot + "/*.*")
               system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
               system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end if
         end if
         delete(KeyWords)
      end if
   end if

   DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/summary"
   system ("/bin/rm -f " + DataDirPlot + "/*.*")
   system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
   system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
   system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")

   DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/www"
   system ("/bin/rm -f " + DataDirPlot + "/*.html")

   do nv=0,nfun-1
      DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/relationships/" + str_lower(FuncList(nv))
      system ("/bin/rm -f " + DataDirPlot + "/*.*")
      system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
      system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
      system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
   end do
   DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/v2vscore"
   system ("/bin/rm -f " + DataDirPlot + "/*.*")
   system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
   system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
   system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")

   system ("/bin/rm -f " + getenv("ILAMB_OUTPUTDIR") + "/readme/readme*")

end if

if (any(str_lower(FileType).eq.(/"eps", "gif", "jpg", "pdf", "png", "plot", "plots", "ps"/))) then
   if (nvar.gt.1) then
      do nv=0,nvar-1
         KeyWords = systemfunc ("ls " + getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)))
         if (dimsizes(KeyWords).gt.1) then
            do nk=0,dimsizes(KeyWords)-1
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords(nk)
               system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")
               if (any(str_lower(FileType).eq.(/"plot", "plots"/))) then
                  system ("/bin/rm -f " + DataDirPlot + "/*." + PlotType)
                  system ("/bin/rm -f " + DataDirPlot + "/*.png")
               else
                  system ("/bin/rm -f " + DataDirPlot + "/*." + str_lower(FileType))
               end if
            end do
         else
            if (.not.ismissing(KeyWords)) then
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords
               system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")
               if (any(str_lower(FileType).eq.(/"plot", "plots"/))) then
                  system ("/bin/rm -f " + DataDirPlot + "/*." + PlotType)
                  system ("/bin/rm -f " + DataDirPlot + "/*.png")
               else
                  system ("/bin/rm -f " + DataDirPlot + "/*." + str_lower(FileType))
               end if
            end if
         end if
         delete(KeyWords)
      end do
   else
      if (.not.ismissing(VarNames)) then
         KeyWords = systemfunc ("ls " + getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames))
         if (dimsizes(KeyWords).gt.1) then
            do nk=0,dimsizes(KeyWords)-1
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/" + KeyWords(nk)
               system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")
               if (any(str_lower(FileType).eq.(/"plot", "plots"/))) then
                  system ("/bin/rm -f " + DataDirPlot + "/*." + PlotType)
                  system ("/bin/rm -f " + DataDirPlot + "/*.png")
               else
                  system ("/bin/rm -f " + DataDirPlot + "/*." + str_lower(FileType))
               end if
            end do
         else
            if (.not.ismissing(KeyWords)) then
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/" + KeyWords
               system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")
               if (any(str_lower(FileType).eq.(/"plot", "plots"/))) then
                  system ("/bin/rm -f " + DataDirPlot + "/*." + PlotType)
                  system ("/bin/rm -f " + DataDirPlot + "/*.png")
               else
                  system ("/bin/rm -f " + DataDirPlot + "/*." + str_lower(FileType))
               end if
            end if
         end if
         delete(KeyWords)
      end if
   end if

   DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/summary"
   system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")
   if (any(str_lower(FileType).eq.(/"plot", "plots"/))) then
      system ("/bin/rm -f " + DataDirPlot + "/*." + PlotType)
      system ("/bin/rm -f " + DataDirPlot + "/*.png")
   else
      system ("/bin/rm -f " + DataDirPlot + "/*." + str_lower(FileType))
   end if

   do nv=0,nfun-1
      DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/relationships/" + str_lower(FuncList(nv))
      system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")
      if (any(str_lower(FileType).eq.(/"plot", "plots"/))) then
         system ("/bin/rm -f " + DataDirPlot + "/*." + PlotType)
         system ("/bin/rm -f " + DataDirPlot + "/*.png")
      else
         system ("/bin/rm -f " + DataDirPlot + "/*." + str_lower(FileType))
      end if
   end do
   DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/v2vscore"
   system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")
   if (any(str_lower(FileType).eq.(/"plot", "plots"/))) then
      system ("/bin/rm -f " + DataDirPlot + "/*." + PlotType)
      system ("/bin/rm -f " + DataDirPlot + "/*.png")
   else
      system ("/bin/rm -f " + DataDirPlot + "/*." + str_lower(FileType))
   end if
end if

if (any(str_lower(FileType).eq.(/"txt", "text", "table", "tables"/))) then
   if (nvar.gt.1) then
      do nv=0,nvar-1
         KeyWords = systemfunc ("ls " + getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)))
         if (dimsizes(KeyWords).gt.1) then
            do nk=0,dimsizes(KeyWords)-1
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords(nk)
               system ("/bin/rm -f " + DataDirPlot + "/*.txt")
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end do
         else
            if (.not.ismissing(KeyWords)) then
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords
               system ("/bin/rm -f " + DataDirPlot + "/*.txt")
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end if
         end if
         delete(KeyWords)
      end do
   else
      if (.not.ismissing(VarNames)) then
         KeyWords = systemfunc ("ls " + getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames))
         if (dimsizes(KeyWords).gt.1) then
            do nk=0,dimsizes(KeyWords)-1
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/" + KeyWords(nk)
               system ("/bin/rm -f " + DataDirPlot + "/*.txt")
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end do
         else
            if (.not.ismissing(KeyWords)) then
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/" + KeyWords
               system ("/bin/rm -f " + DataDirPlot + "/*.txt")
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end if
         end if
         delete(KeyWords)
      end if
   end if

   DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/summary"
   system ("/bin/rm -f " + DataDirPlot + "/*.txt")
   system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")

   do nv=0,nfun-1
      DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/relationships/" + str_lower(FuncList(nv))
      system ("/bin/rm -f " + DataDirPlot + "/*.txt")
      system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
   end do
   DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/v2vscore"
   system ("/bin/rm -f " + DataDirPlot + "/*.txt")
   system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
end if

if (str_lower(FileType).eq."readme") then
   system ("/bin/rm -f " + getenv("ILAMB_OUTPUTDIR") + "/readme/readme*")
end if

if (any(str_lower(FileType).eq.(/"html", "www"/))) then
   DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/www"
   system ("/bin/rm -f " + DataDirPlot + "/*.html")
end if

end

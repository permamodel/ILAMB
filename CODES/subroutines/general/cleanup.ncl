procedure cleanup (VarNames:string, nvpa:integer, FileType:string)

begin

DataDir = getenv("ILAMB_ROOT")

PlotType = getenv("PLOTTYPE")
PlotType = str_lower(str_squeeze(PlotType))

; retrieve Function Types of Relationships between 2 Variables

FuncType = retrieve_others ("RelationShip", "4")

FuncList = FuncType@funclist

nfun = dimsizes(FuncList)

delete(FuncType)

nvar=dimsizes(VarNames)

print("                                                                       ")
print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
print("Clean Up All Directories and Nonused Files")

; +++++++++ move eps, png and txt files to their own directories ++++++++++

if (nvar.gt.1) then
   do nv=0,nvar-1
      KeyWords = systemfunc ("ls " + getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)))
      if (dimsizes(KeyWords).gt.1) then
         do nk=0,dimsizes(KeyWords)-1
            DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords(nk)
            system ("/bin/mv -f " + DataDirPlot + "/*." + PlotType + " " + DataDirPlot + "/plots/EPS/")
            system ("/bin/mv -f " + DataDirPlot + "/*.png " + DataDirPlot + "/plots/PNG/")
            system ("/bin/mv -f " + DataDirPlot + "/*.txt " + DataDirPlot + "/tables/")
         end do
      else
         if (.not.ismissing(KeyWords)) then
            DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords
            system ("/bin/mv -f " + DataDirPlot + "/*." + PlotType + " " + DataDirPlot + "/plots/EPS/")
            system ("/bin/mv -f " + DataDirPlot + "/*.png " + DataDirPlot + "/plots/PNG/")
            system ("/bin/mv -f " + DataDirPlot + "/*.txt " + DataDirPlot + "/tables/")
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
            system ("/bin/mv -f " + DataDirPlot + "/*." + PlotType + " " + DataDirPlot + "/plots/EPS/")
            system ("/bin/mv -f " + DataDirPlot + "/*.png " + DataDirPlot + "/plots/PNG/")
            system ("/bin/mv -f " + DataDirPlot + "/*.txt " + DataDirPlot + "/tables/")
         end do
      else
         if (.not.ismissing(KeyWords)) then
            DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/" + KeyWords
            system ("/bin/mv -f " + DataDirPlot + "/*." + PlotType + " " + DataDirPlot + "/plots/EPS/")
            system ("/bin/mv -f " + DataDirPlot + "/*.png " + DataDirPlot + "/plots/PNG/")
            system ("/bin/mv -f " + DataDirPlot + "/*.txt " + DataDirPlot + "/tables/")
         end if
      end if
      delete(KeyWords)
   end if
end if

DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/summary"
system ("/bin/mv -f " + DataDirPlot + "/*." + PlotType + " " + DataDirPlot + "/plots/EPS/")
system ("/bin/mv -f " + DataDirPlot + "/*.png " + DataDirPlot + "/plots/PNG/")
system ("/bin/mv -f " + DataDirPlot + "/*.txt " + DataDirPlot + "/tables/")

if (nvpa.ge.1) then
   do nv=0,nfun-1
      DataDirPlot1 = getenv("ILAMB_OUTPUTDIR") + "/relationships"
      DataDirPlot2 = getenv("ILAMB_OUTPUTDIR") + "/relationships/" + str_lower(FuncList(nv))
      system ("/bin/mv -f " + DataDirPlot1 + "/" + str_lower(FuncList(nv)) + "*. " + PlotType + " "  + DataDirPlot2 + "/plots/EPS/")
      system ("/bin/mv -f " + DataDirPlot1 + "/" + str_lower(FuncList(nv)) + "*.png " + DataDirPlot2 + "/plots/PNG/")
      system ("/bin/mv -f " + DataDirPlot1 + "/" + str_lower(FuncList(nv)) + "*.txt " + DataDirPlot2 + "/tables/")
   end do
   DataDirPlot1 = getenv("ILAMB_OUTPUTDIR") + "/v2vscore"
   DataDirPlot2 = getenv("ILAMB_OUTPUTDIR") + "/v2vscore"
   system ("/bin/mv -f " + DataDirPlot1 + "/*. " + PlotType + " " + DataDirPlot2 + "/plots/EPS/")
   system ("/bin/mv -f " + DataDirPlot1 + "/*.png " + DataDirPlot2 + "/plots/PNG/")
   system ("/bin/mv -f " + DataDirPlot1 + "/*.txt " + DataDirPlot2 + "/tables/")
end if


; +++++++++ Delete eps, png or txt files bases on the definition of "FileType" ++++++++++

if (str_lower(FileType).eq."all") then
   if (nvar.gt.1) then
      do nv=0,nvar-1
         KeyWords = systemfunc ("ls " + getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)))
         if (dimsizes(KeyWords).gt.1) then
            do nk=0,dimsizes(KeyWords)-1
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords(nk)
               system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
               system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end do
         else
            if (.not.ismissing(KeyWords)) then
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords
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
               system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
               system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end do
         else
            if (.not.ismissing(KeyWords)) then
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/" + KeyWords
               system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
               system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end if
         end if
         delete(KeyWords)
      end if
   end if

   DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/summary"
   system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
   system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
   system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")

   if (nvpa.ge.1) then
      do nv=0,nfun-1
         DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/relationships/" + str_lower(FuncList(nv))
         system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
         system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
         system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
      end do
      DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/v2vscore"
      system ("/bin/rm -f " + DataDirPlot + "/plots/EPS/*." + PlotType)
      system ("/bin/rm -f " + DataDirPlot + "/plots/PNG/*.png")
      system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
   end if
end if

if (str_lower(FileType).eq.PlotType .or. str_lower(FileType).eq."png") then
   if (nvar.gt.1) then
      do nv=0,nvar-1
         KeyWords = systemfunc ("ls " + getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)))
         if (dimsizes(KeyWords).gt.1) then
            do nk=0,dimsizes(KeyWords)-1
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords(nk)
               system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")
            end do
         else
            if (.not.ismissing(KeyWords)) then
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords
               system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")
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
            end do
         else
            if (.not.ismissing(KeyWords)) then
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/" + KeyWords
               system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")
            end if
         end if
         delete(KeyWords)
      end if
   end if

   DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/summary"
   system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")

   if (nvpa.ge.1) then
      do nv=0,nfun-1
         DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/relationships/" + str_lower(FuncList(nv))
         system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")
      end do
      DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/v2vscore"
      system ("/bin/rm -f " + DataDirPlot + "/plots/" + str_upper(FileType) + "/*")
   end if
end if

if (str_lower(FileType).eq."txt") then
   if (nvar.gt.1) then
      do nv=0,nvar-1
         KeyWords = systemfunc ("ls " + getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)))
         if (dimsizes(KeyWords).gt.1) then
            do nk=0,dimsizes(KeyWords)-1
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords(nk)
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end do
         else
            if (.not.ismissing(KeyWords)) then
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords
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
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end do
         else
            if (.not.ismissing(KeyWords)) then
               DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/" + KeyWords
               system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
            end if
         end if
         delete(KeyWords)
      end if
   end if

   DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/summary"
   system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")

   if (nvpa.ge.1) then
      do nv=0,nfun-1
         DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/relationships/" + str_lower(FuncList(nv))
         system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
      end do
      DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/v2vscore"
      system ("/bin/rm -f " + DataDirPlot + "/tables/*.txt")
   end if
end if

end

procedure convert_to_png (VarNames:string)

begin

PlotType = getenv("PLOTTYPE")
PlotType = str_lower(str_squeeze(PlotType))

DataDir = getenv("ILAMB_ROOT")

nvar=dimsizes(VarNames)

; +++++++++++++++ search all plot files and convert them to PNG +++++++++++

print("                                                                       ")
print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
print("Converting plot files to PNG")

if (nvar.gt.1) then
   do nv=0,nvar-1
      KeyWords = systemfunc ("ls " + getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)))
      if (dimsizes(KeyWords).gt.1) then
         do nk=0,dimsizes(KeyWords)-1
            DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords(nk)
            ;EpsFiles = systemfunc ("ls " + DataDirPlot + "/" + KeyWords(nk) + "*.eps")
            EpsFiles = systemfunc ("ls " + DataDirPlot + "/" + "*." + PlotType)
            system ("cd " + DataDirPlot)
            if (dimsizes(EpsFiles).gt.1) then
               do ns=0,dimsizes(EpsFiles)-1
                  cEpsFile = stringtochar(EpsFiles(ns))
                  cEpsFile = cEpsFile(::-1)
                  cEpsFiles= cEpsFile(4:)
                  PngFile  = chartostring(cEpsFiles(::-1)) + "png"
                  delete(cEpsFile)
                  delete(cEpsFiles)
                  ;print(EpsFiles(ns))
                  ;print(PngFile)
                  if (isStrSubset(str_lower(EpsFiles(ns)), "check") .and. isStrSubset(str_lower(EpsFiles(ns)), "annualmean")) then
                     system ("convert -trim -density 300 " + EpsFiles(ns) + " " + PngFile)
                  else
                     system ("convert -trim -density 150 " + EpsFiles(ns) + " " + PngFile)
                  end if
               end do
            else
               if (.not.ismissing(EpsFiles)) then
                  cEpsFile = stringtochar(EpsFiles)
                  cEpsFile = cEpsFile(::-1)
                  cEpsFiles= cEpsFile(4:)
                  PngFile  = chartostring(cEpsFiles(::-1)) + "png"
                  delete(cEpsFile)
                  delete(cEpsFiles)
                  ;print(EpsFiles)
                  ;print(PngFile)
                  if (isStrSubset(str_lower(EpsFiles), "check") .and. isStrSubset(str_lower(EpsFiles), "annualmean")) then
                     system ("convert -trim -density 300 " + EpsFiles + " " + PngFile)
                  else
                     system ("convert -trim -density 150 " + EpsFiles + " " + PngFile)
                  end if
               end if
            end if
            delete(EpsFiles)
         end do
      else
         if (.not.ismissing(KeyWords)) then
            DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames(nv)) + "/" + KeyWords
            ;EpsFiles = systemfunc ("ls " + DataDirPlot + "/" + KeyWords + "*.eps")
            EpsFiles = systemfunc ("ls " + DataDirPlot + "/" + "*." + PlotType)
            system ("cd " + DataDirPlot)
            if (dimsizes(EpsFiles).gt.1) then
               do ns=0,dimsizes(EpsFiles)-1
                  cEpsFile = stringtochar(EpsFiles(ns))
                  cEpsFile = cEpsFile(::-1)
                  cEpsFiles = cEpsFile(4:)
                  PngFile  = chartostring(cEpsFiles(::-1)) + "png"
                  delete(cEpsFile)
                  delete(cEpsFiles)
                  ;print(EpsFiles(ns))
                  ;print(PngFile)
                  if (isStrSubset(str_lower(EpsFiles(ns)), "check") .and. isStrSubset(str_lower(EpsFiles(ns)), "annualmean")) then
                     system ("convert -trim -density 300 " + EpsFiles(ns) + " " + PngFile)
                  else
                     system ("convert -trim -density 150 " + EpsFiles(ns) + " " + PngFile)
                  end if
               end do
            else
               if (.not.ismissing(EpsFiles)) then
                  cEpsFile = stringtochar(EpsFiles)
                  cEpsFile = cEpsFile(::-1)
                  cEpsFiles = cEpsFile(4:)
                  PngFile  = chartostring(cEpsFiles(::-1)) + "png"
                  delete(cEpsFile)
                  delete(cEpsFiles)
                  ;print(EpsFiles)
                  ;print(PngFile)
                  if (isStrSubset(str_lower(EpsFiles), "check") .and. isStrSubset(str_lower(EpsFiles), "annualmean")) then
                     system ("convert -trim -density 300 " + EpsFiles + " " + PngFile)
                  else
                     system ("convert -trim -density 150 " + EpsFiles + " " + PngFile)
                  end if
               end if
            end if
            delete(EpsFiles)
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
            ;EpsFiles = systemfunc ("ls " + DataDirPlot + "/" + KeyWords(nk) + "*.eps")
            EpsFiles = systemfunc ("ls " + DataDirPlot + "/" + "*." + PlotType)
            system ("cd " + DataDirPlot)
            if (dimsizes(EpsFiles).gt.1) then
               do ns=0,dimsizes(EpsFiles)-1
                  cEpsFile = stringtochar(EpsFiles(ns))
                  cEpsFile = cEpsFile(::-1)
                  cEpsFiles = cEpsFile(4:)
                  PngFile  = chartostring(cEpsFiles(::-1)) + "png"
                  delete(cEpsFile)
                  delete(cEpsFiles)
                  ;print(EpsFiles(ns))
                  ;print(PngFile)
                  if (isStrSubset(str_lower(EpsFiles(ns)), "check") .and. isStrSubset(str_lower(EpsFiles(ns)), "annualmean")) then
                     system ("convert -trim -density 300 " + EpsFiles(ns) + " " + PngFile)
                  else
                     system ("convert -trim -density 150 " + EpsFiles(ns) + " " + PngFile)
                  end if
               end do
            else
               if (.not.ismissing(EpsFiles)) then
                  cEpsFile = stringtochar(EpsFiles)
                  cEpsFile = cEpsFile(::-1)
                  cEpsFiles = cEpsFile(4:)
                  PngFile  = chartostring(cEpsFiles(::-1)) + "png"
                  delete(cEpsFile)
                  delete(cEpsFiles)
                  ;print(EpsFiles)
                  ;print(PngFile)
                  if (isStrSubset(str_lower(EpsFiles), "check") .and. isStrSubset(str_lower(EpsFiles), "annualmean")) then
                     system ("convert -trim -density 300 " + EpsFiles + " " + PngFile)
                  else
                     system ("convert -trim -density 150 " + EpsFiles + " " + PngFile)
                  end if
               end if
            end if
            delete(EpsFiles)
         end do
      else
         if (.not.ismissing(KeyWords)) then
            DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/" + str_lower(VarNames) + "/" + KeyWords
            ;EpsFiles = systemfunc ("ls " + DataDirPlot + "/" + KeyWords + "*.eps")
            EpsFiles = systemfunc ("ls " + DataDirPlot + "/" + "*." + PlotType)
            system ("cd " + DataDirPlot)
            if (dimsizes(EpsFiles).gt.1) then
               do ns=0,dimsizes(EpsFiles)-1
                  cEpsFile = stringtochar(EpsFiles(ns))
                  cEpsFile = cEpsFile(::-1)
                  cEpsFiles = cEpsFile(4:)
                  PngFile  = chartostring(cEpsFiles(::-1)) + "png"
                  delete(cEpsFile)
                  delete(cEpsFiles)
                  ;print(EpsFiles(ns))
                  ;print(PngFile)
                  if (isStrSubset(str_lower(EpsFiles(ns)), "check") .and. isStrSubset(str_lower(EpsFiles(ns)), "annualmean")) then
                     system ("convert -trim -density 300 " + EpsFiles(ns) + " " + PngFile)
                  else
                     system ("convert -trim -density 150 " + EpsFiles(ns) + " " + PngFile)
                  end if
               end do
            else
               if (.not.ismissing(EpsFiles)) then
                  cEpsFile = stringtochar(EpsFiles)
                  cEpsFile = cEpsFile(::-1)
                  cEpsFiles = cEpsFile(4:)
                  PngFile  = chartostring(cEpsFiles(::-1)) + "png"
                  delete(cEpsFile)
                  delete(cEpsFiles)
                  ;print(EpsFiles)
                  ;print(PngFile)
                  if (isStrSubset(str_lower(EpsFiles), "check") .and. isStrSubset(str_lower(EpsFiles), "annualmean")) then
                     system ("convert -trim -density 300 " + EpsFiles + " " + PngFile)
                  else
                     system ("convert -trim -density 150 " + EpsFiles + " " + PngFile)
                  end if
               end if
            end if
            delete(EpsFiles)
         end if
      end if
      delete(KeyWords)
   end if
end if

DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/summary"
EpsFiles = systemfunc ("ls " + DataDirPlot + "/overallscore*." + PlotType)
system ("cd " + DataDirPlot)
if (dimsizes(EpsFiles).gt.1) then
   do ns=0,dimsizes(EpsFiles)-1
      cEpsFile = stringtochar(EpsFiles(ns))
      cEpsFile = cEpsFile(::-1)
      cEpsFiles= cEpsFile(4:)
      PngFile  = chartostring(cEpsFiles(::-1)) + "png"
      delete(cEpsFile)
      delete(cEpsFiles)
      ;print(EpsFiles(ns))
      ;print(PngFile)
     system ("convert -trim -density 150 " + EpsFiles(ns) + " " + PngFile)
   end do
else
   if (.not.ismissing(EpsFiles)) then
      cEpsFile = stringtochar(EpsFiles)
      cEpsFile = cEpsFile(::-1)
      cEpsFiles= cEpsFile(4:)
      PngFile  = chartostring(cEpsFiles(::-1)) + "png"
      delete(cEpsFile)
      delete(cEpsFiles)
      ;print(EpsFiles)
      ;print(PngFile)
      system ("convert -trim -density 150 " + EpsFiles + " " + PngFile)
   end if
end if
delete(EpsFiles)

DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/relationships"
EpsFiles = systemfunc ("ls " + DataDirPlot + "/*." + PlotType)
system ("cd " + DataDirPlot)
if (dimsizes(EpsFiles).gt.1) then
   do ns=0,dimsizes(EpsFiles)-1
      cEpsFile = stringtochar(EpsFiles(ns))
      cEpsFile = cEpsFile(::-1)
      cEpsFiles= cEpsFile(4:)
      PngFile  = chartostring(cEpsFiles(::-1)) + "png"
      delete(cEpsFile)
      delete(cEpsFiles)
      ;print(EpsFiles(ns))
      ;print(PngFile)
     system ("convert -trim -density 150 " + EpsFiles(ns) + " " + PngFile)
   end do
else
   if (.not.ismissing(EpsFiles)) then
      cEpsFile = stringtochar(EpsFiles)
      cEpsFile = cEpsFile(::-1)
      cEpsFiles= cEpsFile(4:)
      PngFile  = chartostring(cEpsFiles(::-1)) + "png"
      delete(cEpsFile)
      delete(cEpsFiles)
      ;print(EpsFiles)
      ;print(PngFile)
      system ("convert -trim -density 150 " + EpsFiles + " " + PngFile)
   end if
end if
delete(EpsFiles)

DataDirPlot = getenv("ILAMB_OUTPUTDIR") + "/v2vscore"
EpsFiles = systemfunc ("ls " + DataDirPlot + "/*." + PlotType)
system ("cd " + DataDirPlot)
if (dimsizes(EpsFiles).gt.1) then
   do ns=0,dimsizes(EpsFiles)-1
      cEpsFile = stringtochar(EpsFiles(ns))
      cEpsFile = cEpsFile(::-1)
      cEpsFiles= cEpsFile(4:)
      PngFile  = chartostring(cEpsFiles(::-1)) + "png"
      delete(cEpsFile)
      delete(cEpsFiles)
      ;print(EpsFiles(ns))
      ;print(PngFile)
     system ("convert -trim -density 150 " + EpsFiles(ns) + " " + PngFile)
   end do
else
   if (.not.ismissing(EpsFiles)) then
      cEpsFile = stringtochar(EpsFiles)
      cEpsFile = cEpsFile(::-1)
      cEpsFiles= cEpsFile(4:)
      PngFile  = chartostring(cEpsFiles(::-1)) + "png"
      delete(cEpsFile)
      delete(cEpsFiles)
      ;print(EpsFiles)
      ;print(PngFile)
      system ("convert -trim -density 150 " + EpsFiles + " " + PngFile)
   end if
end if
delete(EpsFiles)

; ++++++++++ go back to main Codes directory ++++++++++++
system ("cd " + DataDir + "/CODES")

end

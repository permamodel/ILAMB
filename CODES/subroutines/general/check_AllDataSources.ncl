function check_AllDataSources (VarName:string)

begin

; ++++++++++++++ retrieve ILAMB Root +++++++++++++++
ILAMBDir = getenv("ILAMB_ROOT")

print("                                                                       ")
print("--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->--->")
print("Searching All Benchmark Data Sources for the Variable: " + VarName)

DataDir = ILAMBDir + "/DATA/" + VarName

DataList = systemfunc ("ls " + DataDir)

DataList = str_squeeze(DataList)

nsur     = dimsizes(DataList)

if (nsur.gt.1) then
   Sources        = new((/nsur/), string)
   do ns = 0, nsur-1
      Source0     = str_split(DataList(ns),"/")
      nlast       = dimsizes(Source0)
      Sources(ns) = Source0(nlast-1)
      delete(Source0)
   end do
else
   Source0        = str_split(DataList,"/")
   nlast          = dimsizes(Source0)
   Sources        = Source0(nlast-1)
   delete(Source0)
end if

delete(DataList)

return(Sources)

end

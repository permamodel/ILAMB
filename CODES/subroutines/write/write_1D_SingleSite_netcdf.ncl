function write_1D_SingleSite_netcdf ( VarName:string, VarLongName:string, VarUnit:string, Title:string, Source:string, TimeStep:string, \
                           data[*]:float, time[*]:double, lat[*]:float, lon[*]:float, FileName:string)

begin

;===================================================================  
  ntim  = dimsizes(time)

  fout  = addfile (FileName, "c")

  fAtt               = True 
  fAtt@title         = Title
  fAtt@source_file   = "This product is generated from " + TimeStep + " " + Source + " observations"
  fAtt@Conventions   = "Please contact Prof. James Randerson (Email: jranders@uci.edu) or Dr. Mingquan Mu (mmu@uci.edu) for any question"
  fAtt@creation_date = systemfunc ("date")                                           
  fileattdef( fout, fAtt ) 

  dimNames = (/"time"/)  
  dimSizes = (/ntim/) 
  dimUnlim = (/True/)   
  filedimdef(fout,dimNames,dimSizes,dimUnlim)

  filevardef(fout, "time" ,typeof(time),"time")                               
  filevardef(fout, VarName, typeof(data), (/"time"/))

  time@long_name = "time"
  time@units     = "days since 1850-01-01"

  data@long_name = VarLongName
  data@units     = VarUnit
  data@calendar  = "gregorian"
  data@latitude  = lat
  data@longitude = lon
  data@latitude_unit  = "degrees_north"
  data@longitude_unit = "degrees_east"

  filevarattdef(fout,VarName,data)
  filevarattdef(fout,"time",time)

  fout->time   = (/ time /)     

  fout->$VarName$   = (/ data /)
                                                                                     
  return (fout)
                                                                                     
end

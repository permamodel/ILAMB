function write_2D_netcdf ( VarName:string, VarLongName:string, VarUnit:string, Title:string, Source:string, TimeStep:string, \
                           data[*][*]:float, time:double, lat[*]:float, lon[*]:float, FileName:string)

begin

;===================================================================  
  nlat  = dimsizes(lat)
  nlon  = dimsizes(lon)

  fout  = addfile (FileName, "c")

  fAtt               = True 
  fAtt@title         = Title
  fAtt@source_file   = "This product is generated from " + TimeStep + " " + Source + " observations"
  fAtt@Conventions   = "Please contact Prof. James Randerson (Email: jranders@uci.edu) or Dr. Mingquan Mu (mmu@uci.edu) for any question"
  fAtt@creation_date = systemfunc ("date")
  fileattdef( fout, fAtt )

  dimNames = (/"lat","lon"/)
  dimSizes = (/nlat,nlon/)
  dimUnlim = (/False,False/)
  filedimdef(fout,dimNames,dimSizes,dimUnlim)

  filevardef(fout, "lat"  ,typeof(lat),"lat")
  filevardef(fout, "lon"  ,typeof(lon),"lon")
  filevardef(fout, VarName, typeof(data), (/"lat","lon"/))

  lon@long_name  = "longitude"
  lon@units      = "degrees_east"

  lat@long_name  = "latitude"
  lat@units      = "degrees_north"

  data@long_name = VarLongName
  data@units     = VarUnit
  data@calendar  = "gregorian"
  data@time      = time
  data@time_unit = "days since 1850-01-01"

  filevarattdef(fout,VarName,data)
  filevarattdef(fout,"lat",lat)
  filevarattdef(fout,"lon",lon)

  fout->lat    = (/ lat /)
  fout->lon    = (/ lon /)
  fout->$VarName$   = (/ data /)

  return (fout)
                                                                                     
end

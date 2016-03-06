function write_1D_MultiSites_netcdf ( VarName:string, VarLongName:string, VarUnit:string, Title:string, Source:string, TimeStep:string, \
                           data[*]:float, sites:string, types:string, times:double, lat[*]:float, lon[*]:float, FileName:string)

begin

;===================================================================  
  ndim  = dimsizes(data)

  fout  = addfile (FileName, "c")

  fAtt               = True 
  fAtt@title         = Title
  fAtt@source_file   = "This product is generated from " + TimeStep + " " + Source + " observations"
  fAtt@Conventions   = "Please contact Prof. James Randerson (Email: jranders@uci.edu) or Dr. Mingquan Mu (mmu@uci.edu) for any question"
  fAtt@creation_date = systemfunc ("date")
  fAtt@site_name     = sites
;  fAtt@IGBP_class    = types ; for FluxNet site observations
  fAtt@altitude      = types  ; for NOAA GMD Site obervations
  fileattdef( fout, fAtt )

  dimNames = (/"data"/)
  dimSizes = (/ndim/)
  dimUnlim = (/False/)
  filedimdef(fout,dimNames,dimSizes,dimUnlim)

  filevardef(fout, "lat"  ,typeof(lat),(/"data"/))
  filevardef(fout, "lon"  ,typeof(lon),(/"data"/))
  filevardef(fout, VarName, typeof(data),(/"data"/))

  lon@long_name  = "longitude"
  lon@units      = "degrees_east"

  lat@long_name  = "latitude"
  lat@units      = "degrees_north"

  data@long_name = VarLongName
  data@units     = VarUnit
  data@time      = times
  data@time_unit = "days since 1850-1-1"

  filevarattdef(fout,VarName,data)
  filevarattdef(fout,"lat",lat)
  filevarattdef(fout,"lon",lon)

  fout->lat    = (/ lat /)
  fout->lon    = (/ lon /)
  fout->$VarName$   = (/ data /)

  return (fout)
                                                                                     
end

;#######################################################################################################################
function read_model_vars ( datadirID:string, cmipID:string, modelID:string, expID:string, runID:string, varID:string)

begin

;===================================================================  

; ++++ cVeg in CLM40cn, CLM45bgc and CLM45bgc_GSWP3 is annual data instead of monthly ++++
;if (any(str_lower(cmipID) .eq. (/"clm40cn", "clm45bgc", "clm45bgc_gswp3"/))) then
;
;   if (any(varID .eq. (/"cVeg", "cSoil"/))) then
;      modelID="Lyr"
;      files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
;                       + modelID + "_" + cmipID + "_" + expID + "_" + runID + "*.nc") 
;
;      if (dimsizes(files).gt.1 .or. .not.ismissing(files)) then
;         print(files)
;         f1 = addfile (files, "r")   
;         ts=f1->$varID$
;
;         nmon=12
;         ndim=dimsizes(ts)
;         nyer=ndim(0)
;         nlat=ndim(1)
;         nlon=ndim(2)
;         ntot=nyer*nmon
;
;         delete(f1)
;         delete(ndim)
;      end if
;   else
;      files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
;                       + modelID + "_" + cmipID + "_" + expID + "_" + runID + "*.nc") 
;      if (dimsizes(files).gt.1 .or. .not.ismissing(files)) then
;         print(files)
;         f1 = addfile (files, "r")   
;         ts=f1->$varID$
;         delete(f1)
;      end if
;   end if
;
;else

   files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
                    + modelID + "_" + cmipID + "_" + expID + "_" + runID + "*.nc") 

   ;files_ps = systemfunc ("ls " + datadirID + "/" + cmipID + "/ps/ps_" \
   ;                 + modelID + "_" + cmipID + "_" + expID + "_" + runID + "*.nc") 

   ;files_ts = systemfunc ("ls " + datadirID + "/" + cmipID + "/tas/tas_" \
   ;                 + modelID + "_" + cmipID + "_" + expID + "_" + runID + "*.nc") 

   if (dimsizes(files).gt.1) then
      print(files)

      if (str_lower(varID).eq."co2") then

         f1 = addfile (files(0), "r")   
         tmp=f1->$varID$
         plev=f1->plev

         ;f2 = addfile (files_ps(0), "r")   
         ;tmp2=f2->ps

         ;f3 = addfile (files_ts(0), "r")   
         ;tmp3=f3->tas

         plev=plev/100.
         i50 = minind(abs(plev-500.)) 

         ndim = dimsizes(tmp)
         ntot0 = ndim(0)
         nlev0 = ndim(1)
         nlat0 = ndim(2)
         nlon0 = ndim(3)

         ntot = (2005-1849)*12

         ts0=new((/ntot,nlat0,nlon0/), float)

         tmp1 = linmsg_n(tmp, -1, 1)
         ts0(0:ntot0-1,:,:) = tmp1(:,0,:,:)

         ;do nt = 0, ntot0-1
         ;do ny = 0, nlat0-1
         ;do nx = 0, nlon0-1
         ;   j50 = ind(.not.ismissing(tmp(nt,:,ny,nx)))
         ;   ts0(nt,ny,nx) = tmp(nt,j50(0),ny,nx)
         ;   delete(j50)
         ;end do
         ;end do
         ;end do

         ;ts0(0:ntot0-1,:,:) = tmp(:,i50,:,:)
         delete(tmp)
         delete(tmp1)
         delete(ndim)

         do nfs = 1, dimsizes(files)-1
            f1 = addfile (files(nfs), "r")   
            tmp=f1->$varID$
            ndim = dimsizes(tmp)
            ntot1 = ndim(0)

            tmp1 = linmsg_n(tmp, -1, 1)
            ts0(ntot0:ntot0+ntot1-1,:,:) = tmp1(:,0,:,:)

            ;do nt = 0, ntot1-1
            ;do ny = 0, nlat0-1
            ;do nx = 0, nlon0-1
            ;   j50 = ind(.not.ismissing(tmp(nt,:,ny,nx)))
            ;   ts0(ntot0+nt,ny,nx) = tmp(nt,j50(0),ny,nx)
            ;   delete(j50)
            ;end do
            ;end do
            ;end do

            ;ts0(ntot0:ntot0+ntot1-1,:,:) = tmp(:,i50,:,:)
            ntot0 = ntot0 + ntot1
            delete(tmp)
            delete(tmp1)
            delete(ndim)
         end do

         ts = ts0(0:ntot0-1,:,:)

         delete(i50)
         delete(plev)
         delete(ts0)

      else

         fin = addfiles (files, "r")   

         ListSetType (fin, "cat")

         ts = addfiles_GetVar(fin, files, varID)
      end if
   else
      if (.not.ismissing(files)) then
         print(files)

         if (str_lower(varID).eq."co2") then
            f1 = addfile (files, "r")   
            tmp=f1->$varID$
            plev=f1->plev

            plev=plev/100.
            i50 = minind(abs(plev-500.)) 

            ndim = dimsizes(tmp)
            ntot0 = ndim(0)
            nlev0 = ndim(1)
            nlat0 = ndim(2)
            nlon0 = ndim(3)

            ts0=new((/ntot0,nlat0,nlon0/), float)

            tmp1 = linmsg_n(tmp, -1, 1)
            ts0(0:ntot0-1,:,:) = tmp1(:,0,:,:)
            
            ;do nt = 0, ntot0-1
            ;do ny = 0, nlat0-1
            ;do nx = 0, nlon0-1
            ;   j50 = ind(.not.ismissing(tmp(nt,:,ny,nx)))
            ;   ts0(nt,ny,nx) = tmp(nt,j50(0),ny,nx)
            ;   delete(j50)
            ;end do
            ;end do
            ;end do
            
            ts = ts0(0:ntot0-1,:,:)
            ;ts = tmp(:,i50,:,:)
            
            ;delete(ts0)
            delete(tmp)
            delete(tmp1)
            delete(i50)
            delete(plev)
            delete(ndim)
         else
            f1 = addfile (files, "r")   
            ts=f1->$varID$
         end if
      end if

   end if
;end if

if (isdefined("ts")) then
else
   ts = 0.0
end if

;printVarSummary (ts)

return (ts)
                                                                                     
end

;#######################################################################################################################
function read_model_latlon ( datadirID:string, cmipID:string, modelID:string, expID:string, runID:string, varID:string)

begin

;===================================================================  

; ++++ cVeg in CLM40cn, CLM45bgc and CLM45bgc_GSWP3 is annual data instead of monthly ++++
;if (any(str_lower(cmipID) .eq. (/"clm40cn", "clm45bgc", "clm45bgc_gswp3"/))) then

   ;if (any(varID .eq. (/"cVeg", "cSoil"/))) then
   ;   modelID="Lyr"
   ;   files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
   ;                    + modelID + "_" + cmipID + "_" + expID + "_" + runID + "*.nc") 
   ;else

      files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
                          + modelID + "_" + cmipID + "_" + expID + "_" + runID + "_*.nc") 
   ;end if

   ;print(files)

   ;f1 = addfile (files, "r")   
   ;slon=f1->lon
   ;slat=f1->lat
   ;delete(f1)

;else

   files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
                          + modelID + "_" + cmipID + "_" + expID + "_" + runID + "_*.nc") 
   print(files)

   if (dimsizes(files).eq.1) then
      fin = addfiles (files, "r")   
      ListSetType (fin, "cat")
      lons = addfiles_GetVar(fin, files, "lon")
      lats = addfiles_GetVar(fin, files, "lat")
   else
      fin = addfiles (files(0), "r")   
      ListSetType (fin, "cat")
      lons = addfiles_GetVar(fin, files(0), "lon")
      lats = addfiles_GetVar(fin, files(0), "lat")
   end if

   if (isdouble(lons)) then
      slon=dble2flt(lons)
      slat=dble2flt(lats)
   else
      slon=lons
      slat=lats
   end if

;end if

results = 1
results@lat = slat
results@lon = slon

;printVarSummary (slon)

return (results)
                                                                                     
end

;#######################################################################################################################
function read_model_lon ( datadirID:string, cmipID:string, modelID:string, expID:string, runID:string, varID:string)

begin

;===================================================================  

; ++++ cVeg in CLM40cn, CLM45bgc and CLM45bgc_GSWP3 is annual data instead of monthly ++++
if (any(str_lower(cmipID) .eq. (/"clm40cn", "clm45bgc", "clm45bgc_gswp3"/))) then

   if (any(varID .eq. (/"cVeg", "cSoil"/))) then
      modelID="Lyr"
      files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
                       + modelID + "_" + cmipID + "_" + expID + "_" + runID + "*.nc") 
   else

      files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
                          + modelID + "_" + cmipID + "_" + expID + "_" + runID + "_*.nc") 
   end if

   print(files)

   f1 = addfile (files, "r")   
   slon=f1->lon
   delete(f1)

else

   files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
                          + modelID + "_" + cmipID + "_" + expID + "_" + runID + "_*.nc") 
   print(files)

   if (dimsizes(files).eq.1) then
      fin = addfiles (files, "r")   
      ListSetType (fin, "cat")
      lons = addfiles_GetVar(fin, files, "lon")
   else
      fin = addfiles (files(0), "r")   
      ListSetType (fin, "cat")
      lons = addfiles_GetVar(fin, files(0), "lon")
   end if

   if (isdouble(lons)) then
      slon=dble2flt(lons)
   else
      slon=lons
   end if

end if

;printVarSummary (slon)

return (slon)
                                                                                     
end

;#######################################################################################################################
function read_model_lat ( datadirID:string, cmipID:string, modelID:string, expID:string, runID:string, varID:string)

begin

;===================================================================  

; ++++ cVeg in CLM40cn, CLM45bgc and CLM45bgc_GSWP3 is annual data instead of monthly ++++
if (any(str_lower(cmipID) .eq. (/"clm40cn", "clm45bgc", "clm45bgc_gswp3"/))) then

   if (any(varID .eq. (/"cVeg", "cSoil"/))) then
      modelID="Lyr"
      files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
                       + modelID + "_" + cmipID + "_" + expID + "_" + runID + "*.nc") 
   else
      files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
                          + modelID + "_" + cmipID + "_" + expID + "_" + runID + "_*.nc") 
   end if

   print(files)

   f1 = addfile (files, "r")   
   slat=f1->lat
   delete(f1)

else

   files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
                          + modelID + "_" + cmipID + "_" + expID + "_" + runID + "_*.nc") 

   print(files)

   if (dimsizes(files).eq.1) then
      fin = addfiles (files, "r")   
      ListSetType (fin, "cat")
      lats = addfiles_GetVar(fin, files, "lat")
   else
      fin = addfiles (files(0), "r")   
      ListSetType (fin, "cat")
      lats = addfiles_GetVar(fin, files(0), "lat")
   end if

   if (isdouble(lats)) then
      slat=dble2flt(lats)
   else
      slat=lats
   end if

end if

;printVarSummary (slat)

return (slat)
                                                                                     
end

;#######################################################################################################################
function read_model_lev ( datadirID:string, cmipID:string, modelID:string, expID:string, runID:string, varID:string)

begin

;===================================================================  

files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
                          + modelID + "_" + cmipID + "_" + expID + "_" + runID + "_*.nc") 

print(files)

if (dimsizes(files).eq.1) then
   fin = addfiles (files, "r")   
   ListSetType (fin, "cat")
   levs = addfiles_GetVar(fin, files, "plev")
else
   fin = addfiles (files(0), "r")   
   ListSetType (fin, "cat")
   levs = addfiles_GetVar(fin, files(0), "plev")
end if

if (isdouble(levs)) then
   slev=dble2flt(levs)
else
   slev=levs
end if

;printVarSummary (slev)

return (slev)
                                                                                     
end

;#######################################################################################################################
function read_model_time ( datadirID:string, cmipID:string, modelID:string, expID:string, runID:string, varID:string)

begin

;===================================================================  

files = systemfunc ("ls " + datadirID + "/" + cmipID + "/" + varID + "/" + varID + "_" \
                          + modelID + "_" + cmipID + "_" + expID + "_" + runID + "_*.nc") 


if (dimsizes(files).eq.1) then
   fin = addfile (files, "r")
   times=fin->time
else
   fin = addfiles (files, "r")   
   ListSetType (fin, "cat")
   times = addfiles_GetVar(fin, files, "time")
end if

;printVarSummary (times)

return (times)
                                                                                     
end

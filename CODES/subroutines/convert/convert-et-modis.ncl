load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12
nlat0=360
nlon0=720

StartYear=2000
EndYear=2013
nyer=EndYear-StartYear + 1

varID="et"

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

lat0 = fspan(-89.75,89.75,nlat0)
lon0 = fspan(-179.75,179.75, nlon0)

; +++++++ generate data in 0.5x0.5 ++++++++
;nlat=360
;nlon=720
;lat=fspan(-89.75,89.75,nlat)
;lon=fspan(-179.75,179.75,nlon)

; +++++++ generate data in 1x1 ++++++++
nlat=180
nlon=360
lat=fspan( -89.5, 89.5,nlat)
lon=fspan(-179.5,179.5,nlon)

; +++++++ generate data in 2.5x2.5 ++++++++
;nlat1=360
;nlon1=720
;nlat=72
;nlon=144
;lat=fspan( -88.75, 88.75,nlat)
;lon=fspan(-178.75,178.75,nlon)

; ----------------  calculating No.of days from 1850 through 1981  ---------------
   ijk=0
do iiy = 1850, 1999

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      ntim=366
   else
      ntim=365
   end if

   ijk = ijk + ntim
end do

time = int2dble(ijk)

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = varID
VarLongName = "Evapotranspiration"
VarUnit     = "Kg/m2/s"
Title       = "derived MODIS ET"
Source      = "MODIS ET in 0.5x0.5"
TimeStep    = "monthly"

DataDir = "/gdata/randerson3/mmu/ILAMB/DATA/" + str_lower(varID) + "/MODIS"

   ijk=0
do iiy = StartYear, EndYear
   print(iiy)

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      nday(1)=29
   else
      nday(1)=28
   end if

   do iim=1,nmon

   ts0=new((/nlat0,nlon0/), float)
   ts=new((/nlat,nlon/), float)

   ts0 = -999
   ts = -999

   ; ----------------  reading in FluxNet-MTE data  ---------------
   print("reading in MODIS " + varID)

   if (iiy.ge.2013) then
      FileIn=DataDir + "/original/" + sprinti("%0.4i",iiy) + \
           "/MOD16A2_" + str_upper(varID) + "_0.5deg_GEO_" + sprinti("%0.4i",iiy) + "M" + sprinti("%0.2i",iim) + ".hdf"
      print(FileIn)

      f1=addfile(FileIn, "r")
 
      tmp =f1->ET_1km

      tmp1 = short2flt(tmp(::-1,:))

      tmp1 = where(tmp1.eq.32767, -999, tmp1)
      tmp1 = where(ismissing(tmp1), -999, tmp1)

      tmp1@_FillValue = -999

      tmp1 = tmp1/(int2flt(nday(iim-1))*3600*24)

   else
      FileIn=DataDir + "/original/" + sprinti("%0.4i",iiy) + \
           "/MOD16A2_" + str_upper(varID) + "_0.5deg_GEO_" + sprinti("%0.4i",iiy) + "M" + sprinti("%0.2i",iim) + ".nc"
      print(FileIn)

      f1=addfile(FileIn, "r")
 
      tmp =f1->Band1

      tmp1 = short2flt(tmp(::-1,:))

      tmp1 = where(tmp1.eq.32767, -999, tmp1)
      tmp1 = where(ismissing(tmp1), -999, tmp1)

      tmp1@_FillValue = -999

      tmp1 = tmp1*0.1/(int2flt(nday(iim-1))*3600*24)

   end if

   ts0(60:339,:) = tmp1

   ts0@_FillValue = -999

   time = time + int2dble(nday(iim-1))

   ; +++++++ generate data in 0.5x0.5 ++++++++
   ;ts = ts0

   ; +++++++ generate data in 1x1 ++++++++
   do ny=0,nlat0-1,2
   do nx=0,nlon0-1,2
      if (all(ismissing(ts0(ny:ny+1,nx:nx+1)))) then
         ts(ny/2,nx/2)=-999
      else
         ts(ny/2,nx/2)=avg(ts0(ny:ny+1,nx:nx+1))
      end if
   end do
   end do

   ; +++++++ generate data in 2.5x2.5 ++++++++
   ;do ny=0,nlat0-1,5
   ;do nx=0,nlon0-1,5
   ;   if (all(ismissing(ts0(ny:ny+4,nx:nx+4)))) then
   ;      ts(ny/5,nx/5)=-999
   ;   else
   ;      ts(ny/5,nx/5)=avg(ts0(ny:ny+4,nx:nx+4))
   ;   end if
   ;end do
   ;end do

   ; +++++++ generate data in 0.5x0.5 ++++++++   
   ;FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;        "/" + str_lower(varID) + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 1x1 ++++++++   
   FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
           "/" + str_lower(varID) + "_1x1_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   ; +++++++ generate data in 2.5x2.5 ++++++++   
   ;FileOut=DataDir + "/derived/" + sprinti("%0.4i",iiy) + \
   ;        "/" + str_lower(varID) + "_2.5x2.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

   print(FileOut)

   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ts, time, lat, lon, FileOut)

   ijk=ijk+1

   delete(ts)
   delete(ts0)
   delete(tmp)
   delete(tmp1)
end do
end do

end

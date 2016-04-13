load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12

nlat0=720
nlon0=1440

nlat=360
nlon=720

StartYear=2006
EndYear=2010
nyer=EndYear-StartYear + 1

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

lat=fspan(-89.75,89.75,nlat)
lon=fspan(-179.75,179.75,nlon)

area=new((/nlat,nlon/), float)

do ny = 0, nlat-1
   if (ny.eq.0) then
      dlat = abs((lat(1)-lat(0))*0.01745)
   else
      dlat = abs((lat(ny)-lat(ny-1))*0.01745)
   end if
   dy = 6370997.0*dlat
do nx = 0, nlon-1
   if (nx.eq.0) then
      dlon = abs((lon(1)-lon(0))*0.01745)
   else
      dlon = abs((lon(nx)-lon(nx-1))*0.01745)
   end if
   dx = 6370997*cos(0.01745*lat(ny))*dlon
   area(ny,nx)=dx*dy
end do
end do

; ----------------  calculating No.of days from 1850 through 1900  ---------------
   ijk=0
;do iiy = 1850, 1978
do iiy = 1850, 2005

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

delete(ijk)

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "soilm"
VarLongName = "top 10cm soil moisture"
VarUnit     = "kg/m2"
Title       = "derived ECV surface soil moisture"
Source      = "0.25 degree ECV merged satellite soil moisuture"
TimeStep    = "monthly"

; ----------------  reading in AVHRR lai  ---------------
print("reading in ECV soil moisture")

datadir="$ILAMB_DATADIR/soilm/ECV"

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

   ts=new((/nlat,nlon/), float)
 
   ts = 0.0

   ijk=0.0
do iid = 1, nday(iim-1)

   FileIn=datadir + "/original/" + sprinti("%0.4i",iiy) + "/ESACCI-L3S_SOILMOISTURE-SSMV-MERGED-" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) \
                   + sprinti("%0.2i",iid) + "000000-fv00.1.nc"

   if (fileexists(FileIn)) then
      print(FileIn)
   
      f1=addfile(FileIn, "r")

      tmp =f1->sm

      tmp1 = short2flt(tmp(::-1,:))

      tmp1 = where(tmp1.le.-900, 0, tmp1)
      tmp1 = where(ismissing(tmp1), 0, tmp1)
   
      do ny=0,nlat0-1,2
      do nx=0,nlon0-1,2
         ts(ny/2,nx/2) =ts(ny/2,nx/2) + avg(tmp1(ny:ny+1,nx:nx+1))
      end do
      end do

      delete(tmp)
      delete(tmp1)
   
      ijk =ijk + 1.0
   end if
end do

   time = time + int2dble(nday(iim-1))

   ts = ts/ijk

   ts = ts*1000.0*0.1

   print(avg(ts))

   ts = where(ts.le.0, -999, ts)

   ts@_FillValue = -999

   print(avg(ts))

   FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
          "/soilm_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"
   print(FileOut)
   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                        ts, time, lat, lon, FileOut)
end do
end do

end

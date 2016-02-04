load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12

nlat0=3600
nlon0=7200

StartYear=2000
EndYear=2000
nyer=EndYear-StartYear + 1

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

; +++++++ generate data in 0.5x0.5 ++++++++
nlat=360
nlon=720
lat=fspan(-89.75,89.75,nlat)
lon=fspan(-179.75,179.75,nlon)

; +++++++ generate data in 1x1 ++++++++
;nlat=180
;nlon=360
;lat=fspan( -89.5, 89.5,nlat)
;lon=fspan(-179.5,179.5,nlon)

; +++++++ generate data in 2.5x2.5 ++++++++
;nlat1=360
;nlon1=720
;nlat=72
;nlon=144
;lat=fspan( -88.75, 88.75,nlat)
;lon=fspan(-178.75,178.75,nlon)

; ----------------  calculating No.of days from 1850 through 1900  ---------------
   ijk=0
do iiy = 1850, 2000

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
VarName     = "albedo"
VarLongName = "albedo"
VarUnit     = "unitless"
Title       = "derived MODIS MCD43C3"
Source      = "0.05 degree MODIS MCD43C3"
TimeStep    = "monthly"

; ----------------  reading in Albedo  ---------------
print("reading in Albedo")

datadir = "/gdata/randerson3/mmu/ILAMB/DATA/albedo/MODIS"

do iiy = StartYear, EndYear
   print(iiy)

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      nday(1)=29
      ntim   = 366
   else
      nday(1)=28
      ntim   = 366
   end if

   ijk=1
do iim=1,nmon

   time = time + int2dble(nday(iim-1))

   albedo=new((/nlat,nlon,nday(iim-1)/), float)

   albedo=-999

   do iid = 1, nday(iim-1)

      filename = datadir + "/original.v6/" + sprinti("%0.4i",iiy) \
               + "/MCD43C3.A" + sprinti("%0.4i",iiy) + sprinti("%0.3i",ijk)

      files_in = systemfunc("ls " + filename + "*.hdf")

      if (dimsizes(files_in).gt.1) then
         file_in = files_in(0)
      else
         file_in = files_in
      end if

      if (fileexists(file_in)) then

         print(file_in)

         ;setfileoption("bin","ReadByteOrder","BigEndian")

         fin=addfile(file_in,"r")

         tmp=fin->Albedo_WSA_shortwave

         print(tmp@scale_factor)
         print(tmp@add_offset)
         ttt=short2flt(tmp(::-1,:))
         delete(tmp)

         print(dimsizes(ttt))
         print(getvaratts(ttt))
         ttt@_FillValue=-999.

         print(ttt(0,0))

         ; +++++++ generate data in 0.5x0.5 ++++++++
         do ny=0,nlat0-1,10
         do nx=0,nlon0-1,10
            if (all(ismissing(ttt(ny:ny+9,nx:nx+9)))) then
               albedo(ny/10,nx/10,iid-1)=-999
            else
               albedo(ny/10,nx/10,iid-1)=avg(ttt(ny:ny+9,nx:nx+9))
            end if
         end do
         end do

         ; +++++++ generate data in 1x1 ++++++++
         ;do ny=0,nlat0-1,20
         ;do nx=0,nlon0-1,20
         ;   if (all(ismissing(ttt(ny:ny+19,nx:nx+19)))) then
         ;      albedo(ny/20,nx/20,iid-1)=-999
         ;   else
         ;      albedo(ny/20,nx/20,iid-1)=avg(ttt(ny:ny+19,nx:nx+19))
         ;   end if
         ;end do
         ;end do

         ; +++++++ generate data in 2.5x2.5 ++++++++
         ;do ny=0,nlat0-1,50
         ;do nx=0,nlon0-1,50
         ;   if (all(ismissing(ttt(ny:ny+49,nx:nx+49)))) then
         ;      albedo(ny/50,nx/50,iid-1)=-999
         ;   else
         ;      albedo(ny/50,nx/50,iid-1)=avg(ttt(ny:ny+49,nx:nx+49))
         ;   end if
         ;end do
         ;end do

         delete(ttt)
      end if
      ijk=ijk+1
      delete(files_in)
   end do

   albedo@_FillValue = -999

   if (iiy.eq.2000 .and. iim.le.2) then
   else

      ttt=dim_avg(albedo)

      ;tmp=ttt
      ;do nx=0, nlon/2-1
      ;   ttt(:,nx)=tmp(:,nlon/2+nx)
      ;   ttt(:,nlon/2+nx)=tmp(:,nx)
      ;end do
      ;delete(tmp)

      ttt@_FillValue=-999

      ; +++++++ generate data in 0.5x0.5 ++++++++
      FileOut=datadir + "/derived.v6/" + sprinti("%0.4i",iiy) + \
             "/" + VarName + "_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

      ; +++++++ generate data in 1x1 ++++++++
      ;FileOut=datadir + "/derived.v6/" + sprinti("%0.4i",iiy) + \
      ;       "/" + VarName + "_1x1_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

      ; +++++++ generate data in 2.5x2.5 ++++++++
      ;FileOut=datadir + "/derived.v6/" + sprinti("%0.4i",iiy) + \
      ;       "/" + VarName + "_2.5x2.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"

      print(FileOut)

      tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ttt, time, lat, lon, FileOut)

      delete(ttt)
      delete(tttt)
   end if
   delete(albedo)
end do
end do

end

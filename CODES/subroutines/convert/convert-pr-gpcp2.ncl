load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

load "$ILAMB_ROOT/CODES/subroutines/write/write_2D_netcdf.ncl"

begin

nmon=12
nlat1=72
nlon1=144
nlat2=360
nlon2=720

start_year=1979
end_year=2012
nyer=end_year-start_year + 1

ntot=nyer*nmon

lat1=fspan(-88.75,88.75,nlat1)
lon1=fspan(1.25,358.75,nlon1)

lat2=fspan(-89.75,89.75,nlat2)
lon2=fspan(-179.75,179.75,nlon2)

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

; ----------------  reading in GPCP2 pr  ---------------
print("reading in pr")

datadir="/gdata/randerson3/mmu/ILAMB/DATA/pr/GPCP2"

; ------- read gpcp2 data -----
ts1=new((/ntot,nlat1,nlon1/), float)

   ijk=0
do iiy = start_year, end_year
   print(iiy)

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      nday(1)=29
   else
      nday(1)=28
   end if

   delete(year1)
   delete(year2)

   setfileoption("bin","ReadByteOrder","BigEndian")
   file_in=datadir + "/original/" + sprinti("%0.4i",iiy) + "/gpcp_v2.2_psg." + sprinti("%0.4i",iiy)
   print(file_in)

   info=fbindirread(file_in,0,(/nlon1/),"integer")
;   info=fbindirread(file_in,0,(/nlon1/),"character")
;   print(info)

   pr1=new((/nlat1,nlon1/), float)

   ij=0
do im=0,nmon-1

   do j=0,nlat1-1
      ij=ij+1
      pr1(j,:)=fbindirread(file_in,ij,(/nlon1/),"float")
   end do

   pr=pr1(::-1,:)
   pr=where(pr.lt.-100., -999, pr)
;   pr=where(reg.eq.0, -999, pr)

   pr@_FillValue=-999

   ts1(ijk,:,:)=pr/(24.0*3600.0)

   pr=where(pr.lt.0., -999, pr)

   delete(pr)

   ijk=ijk+1
end do
   delete(pr1)
end do

opt = True
opt@critpc = 0

ts2  = area_conserve_remap (lon1, lat1, ts1, lon2, lat2, False)

ts2!0="time"
ts2!1="lat"
ts2!2="lon"

; ++++++++++++ save data in netcdf format ++++++++++++++++
VarName     = "pr"
VarLongName = "precipitation"
VarUnit     = "Kg m-2 s-1"
Title       = "derived GPCP version 2 precipitation"
Source      = "GPCP version 2 precipitation"
TimeStep    = "monthly"

   ij=0
do iiy = 1850, start_year-1

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      ntim = 366
   else
      ntim = 365
   end if

   ij = ij + ntim
end do

time = int2dble(ij)

   ijk=0
do iiy = start_year, end_year
do iim = 1, nmon

   year1=int2flt(iiy/4)
   year2=int2flt(iiy)/4.0

   if (year1.eq.year2) then
      nday(1) = 29
   else
      nday(1) = 28
   end if

   time = time + nday(iim-1)

   ts=ts2(ijk,:,:)

   FileOut=datadir + "/derived/" + sprinti("%0.4i",iiy) + \
           "/pr_0.5x0.5_" + sprinti("%0.4i",iiy) + sprinti("%0.2i",iim) + ".nc"
   print(FileOut)
   tttt = write_2D_netcdf (VarName, VarLongName, VarUnit, Title, Source, TimeStep, \
                           ts, time, lat2, lon2, FileOut)

   ijk=ijk+1
   delete(ts)
end do
end do

end

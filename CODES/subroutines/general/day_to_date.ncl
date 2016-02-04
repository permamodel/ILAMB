function day_to_date (year:integer, date:integer)

local nday

; This function is used to convert any day to the date of the fixed year

begin

var_output=new((/2/), integer)

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

var1=int2flt(year/4)
var2=int2flt(year)/4.0

if (var1.eq.var2) then
      nday(1)=29
   else
      nday(1)=28
end if

   ijk=1
do im=0,11
   iim=im+1
do id=0,nday(im)-1
   iid=id+1
   if (date.eq.ijk) then
      month=iim
      day=iid
   end if
      ijk=ijk+1
end do
end do

var_output(0)=month
var_output(1)=day

return(var_output) 

end

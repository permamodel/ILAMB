function date_to_day (year:integer, month:integer, day:integer)

local nday

; This function is used to convert date (year,month and day) to the day of the year

begin

nday= (/31,28,31,30,31,30,31,31,30,31,30,31/)

var1=int2flt(year/4)
var2=int2flt(year)/4.0

if (var1.eq.var2) then
      nday(1)=29
   else
      nday(1)=28
end if

   ijk=0
do im=0,month-2
do id=0,nday(im)-1
   ijk=ijk+1
end do
end do

do id=0,day-1
   ijk=ijk+1
end do

var_output=ijk

return(var_output) 

end

function main

%% clearing
    fclose all; close all; clear all;
    clc; pause(0.1);

%% read in data

nmon=12
nlat=360
nlon=720

smon=['jan';'feb';'mar';'apr';'may';'jun';'jul';'aug';'sep';'oct';'nov';'dec']
smon

datadir='$ILAMB/DATA/lai/AVHRR/'

for (iiy=1982:2010)
for (iim=1:12)
   
    filename1=[datadir,'/original/AVHRRBUVI01.', num2str(iiy, '%4.4d'), smon(iim,:),'a.abf'];
%%    filename1='/gdata/randerson2/mmu/ILAMB/datasets/BENCHMARKS/avhrr/datasets/LAI/original/AVHRRBUVI01.1985junb.abl'

%%    whos '-file' 'filename1'

    fid1=fopen(filename1,'r');
    if fid1==-1
       error('Cant open the file!');
    else
       filename1
       data=fread(fid1,[2160,4320],'uint8',0,'ieee-be');
       fclose(fid1);
       data=data*0.1;
       imagesc(data);

       filename=[datadir,'/original/temp/lai_', num2str(iiy, '%4.4d'), num2str(iim, '%2.2d'), 'a.dat'];
       filename

       fid = fopen(filename, 'wt');
%%     fprintf(fid2, '%12.4f', data1);
       fwrite(fid, data);
       fclose(fid);
    end

end
end

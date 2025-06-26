% clc;
% clear;
% close all;
% warning off;
%% 1ch to modelsim file
filename=[datestr(now,30)];
fid = fopen(['..\data\',filename,'.txt'], 'wt');
if size(rxdata,2)==1
    for i=1:size(rxdata,1)
        fprintf(fid,'%8.0f%8.0f\n',real(rxdata(i)),imag(rxdata(i)));
    end
else
    for i=1:size(rxdata,1)
        fprintf(fid,'%8.0f%8.0f%8.0f%8.0f\n',real(rxdata(i,1)),imag(rxdata(i,1)), ...
            real(rxdata(i,2)),imag(rxdata(i,2)));
    end
end
fclose('all');
%% save to litepoint
flt1=rcosine(1,2,'fir/sqrt',0.05,64);
rx_signal_80=rcosflt(rx_signal_40,1,2, 'filter', flt1);
template=importdata('E:\matlab_work\litepoint\mcs0_100.mat');
info2=template.info2;
wavelp=template.wavelp;
wave=rx_signal_80(:,1);
wavelp.vsg.wave.data=rx_signal_80;
save('e:\matlab_work\02.mat','info2','wavelp','wave');
disp('save to file ok');
%% 2ch to modelsim file
close all;clear;clc;
m = csvread('..\data\data.csv',2,0);
d1un_q=bin2dec(num2str(m(:,21),12));
d1un_i=bin2dec(num2str(m(:,18),12));
d2un_q=bin2dec(num2str(m(:,27),12));
d2un_i=bin2dec(num2str(m(:,24),12));
d1_q=d1un_q-(d1un_q>2^11)*2^12;
d1_i=d1un_i-(d1un_i>2^11)*2^12;
d2_q=d2un_q-(d2un_q>2^11)*2^12;
d2_i=d2un_i-(d2un_i>2^11)*2^12;
% save to file
filename=[datestr(now,30)];
fid = fopen(['..\data\',filename,'.txt'], 'wt');
for i=1:length(d1_q)
    fprintf(fid,'%8.0f%8.0f%8.0f%8.0f\n',d1_i(i),d1_q(i),d2_i(i),d2_q(i));
end
fclose('all');
%% change to hex
bitr(:,1:8)=reshape(bits,8,length(bits)/8).';
for i=1:size(bitr,1)
    dec1(:,i)=bin2dec(num2str(bitr(i,:)));
end
hex1=dec2hex(dec1);
function ret=save_to_file(tx_11b,sim_options)
tx_11b=tx_11b';
file_name=['frame',num2str(sim_options.rate),'_',num2str(sim_options.length)];
% to modelsim
c1=max([abs(real(tx_11b)),abs(imag(tx_11b))]);
index=25000/c1;
txdata=round(tx_11b.*index);
fid = fopen(['..\data\',file_name,'.txt'], 'wt');
for i=1:length(txdata)
    fprintf(fid,'%8.0f%8.0f\n',real(txdata(i)),imag(txdata(i)));
end
%% save to .dat
% c1=max([abs(real(tx_11a)),abs(imag(tx_11a))]);
% index=25000/c1;
% A=round(tx_11a.*index);
% B=zeros(length(A)*2,1);
% B(1:2:end)=real(A);
% B(2:2:end)=imag(A);
% % add pad
% rem=-1;
% i=0;
% while (rem<0)
%     rem=1024*2^i-length(B);
%     i=i+1;
% end
% txdata1=[B;zeros(rem,1)];
% fid2=fopen(['..\data\',file_name,'_16bit.dat'],'w');
% fwrite(fid2,txdata1,'int16');
% fclose('all');
%% save to litepoint
template=importdata('..\data\wave5.mat');
info2=template.info2;
iqw_spec=template.iqw_spec;
fir = rcosdesign(0.5,200,20);
tx1 = upfirdn(tx_11b,fir,20);
tx2=tx1(1:11:end);
figure(2);
pwelch(tx2,[],[],[],80e6,'centered','psd');
wave=tx2;
save(['..\data\',file_name,'.mat'],'info2','iqw_spec','wave');
ret='save to file ok';
disp('save to file ok');
function ret=send_to_yunsdr(tx_11b,yunsdr_init)
samp_hex=dec2hex(yunsdr_init.samp,8);           %sample freq 4e6~61.44e6
bw_hex=dec2hex(yunsdr_init.bw,8);               %fir bandwidth 250e3~56e6
freq_hex=dec2hex(yunsdr_init.freq,10);          %rx LO freq 70e6~6000e6
tx_att1=dec2hex(yunsdr_init.tx_att1,8);         %tx att ch1 0~90e3 mdB
tx_att2=dec2hex(yunsdr_init.tx_att2,8);         %tx att ch2 0~90e3 mdB
rcount=dec2hex(yunsdr_init.rcount,4);           %refclkin/rcount = 26MHz/ncount
ncount=dec2hex(yunsdr_init.ncount,4);           %
ref_hex=dec2hex(yunsdr_init.ref,8);             %1=external ref 0=internal ref
vco_cal_hex=dec2hex(yunsdr_init.vco_cal,8);     %vco=1 refclk of ad9361 from auxdac
aux_dac1_hex=dec2hex(yunsdr_init.aux_dac1,8);   %aux_dac 0~3000mv
fdd_tdd_hex=dec2hex(yunsdr_init.fdd_tdd,8);     %fdd=1,tdd=0
trx_sw_hex=dec2hex(yunsdr_init.trx_sw,8);       %fdd mode trx=1; tdd trx=1 when tx mode
tx_chan=yunsdr_init.tx_chan;                    %1=tx1;2=tx2;3=tx1&tx2
%% 16bit quantification
c1=max([abs(real(tx_11b)),abs(imag(tx_11b))]);
index=25000/c1;
txdata=round(tx_11b.*index);
%% copy to 2chanel
if tx_chan==1 || tx_chan==2
    txdata2=txdata;
elseif tx_chan==3
    txdata2=zeros(1,length(txdata)*2);
    txdata2(1:2:end)=txdata;
    txdata2(2:2:end)=txdata;
end
%% iq mux
txdatas=zeros(1,length(txdata2)*2);
txdatas(1:2:end)=real(txdata2);
txdatas(2:2:end)=imag(txdata2);
%% add pad
rem=-1;
i=0;
while (rem<0)
    rem=1024*2^i-length(txdatas);
    i=i+1;
end
txdata1=[txdatas zeros(1,rem)];
%% tcpip
txd1=(txdata1<0)*65536+txdata1;
txd2=dec2hex(txd1,4);
txd3=txd2(:,1:2);
txd4=txd2(:,3:4);
txd5=hex2dec(txd3);
txd6=hex2dec(txd4);
txd7=zeros(length(txd6)*2,1);
txd7(1:2:end)=txd6;
txd7(2:2:end)=txd5;
%% open control port
ctrl_link = udp('192.168.1.10', 5006);
fopen(ctrl_link);
%% open data port
data_link = tcpip('192.168.1.10', 5005);
set(data_link,'InputBufferSize',16*1024);
set(data_link,'OutputBufferSize',10*1024*1024);
fopen(data_link);
%% tx samp rate
samp=[0 5 hex2dec('22') hex2dec('f0') hex2dec(samp_hex(7:8)) hex2dec(samp_hex(5:6)) hex2dec(samp_hex(3:4)) hex2dec(samp_hex(1:2))];
fwrite(ctrl_link,samp,'uint8');
%% tx bandwidth rate
bw=[0 7 hex2dec('22') hex2dec('f0') hex2dec(bw_hex(7:8)) hex2dec(bw_hex(5:6)) hex2dec(bw_hex(3:4)) hex2dec(bw_hex(1:2))];
fwrite(ctrl_link,bw,'uint8');
%% send tx freq set cmd
tx_freq=[hex2dec(freq_hex(1:2)) 3 hex2dec('22') hex2dec('f0') hex2dec(freq_hex(9:10)) hex2dec(freq_hex(7:8)) hex2dec(freq_hex(5:6)) hex2dec(freq_hex(3:4))];
fwrite(ctrl_link,tx_freq,'uint8');
%% send tx vga set cmd
tx_vga=[0 9 hex2dec('22') hex2dec('f0') hex2dec(tx_att1(7:8)) hex2dec(tx_att1(5:6)) hex2dec(tx_att1(3:4)) hex2dec(tx_att1(1:2))];  %TX1
fwrite(ctrl_link,tx_vga,'uint8');
tx_vga=[0 11 hex2dec('22') hex2dec('f0') hex2dec(tx_att2(7:8)) hex2dec(tx_att2(5:6)) hex2dec(tx_att2(3:4)) hex2dec(tx_att2(1:2))]; %TX2
fwrite(ctrl_link,tx_vga,'uint8');
%% send tx channel set cmd
channel=[tx_chan 0 hex2dec('20') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link,channel,'uint8');
%% custom rf control command
% adf4001 config
adf4001=[0 40 hex2dec('18') hex2dec('f0') hex2dec(ncount(3:4)) hex2dec(ncount(1:2)) hex2dec(rcount(3:4)) hex2dec(rcount(1:2))];
fwrite(ctrl_link,adf4001,'uint8');
% ref_select
ref_select=[0 40 hex2dec('22') hex2dec('f0') hex2dec(ref_hex(7:8)) hex2dec(ref_hex(5:6)) hex2dec(ref_hex(3:4)) hex2dec(ref_hex(1:2))];
fwrite(ctrl_link,ref_select,'uint8');
% vco_cal_select
vco_cal_select=[0 41 hex2dec('22') hex2dec('f0') hex2dec(vco_cal_hex(7:8)) hex2dec(vco_cal_hex(5:6)) hex2dec(vco_cal_hex(3:4)) hex2dec(vco_cal_hex(1:2))];
fwrite(ctrl_link,vco_cal_select,'uint8');
% fdd_tdd_select
fdd_tdd_select=[0 42 hex2dec('22') hex2dec('f0') hex2dec(fdd_tdd_hex(7:8)) hex2dec(fdd_tdd_hex(5:6)) hex2dec(fdd_tdd_hex(3:4)) hex2dec(fdd_tdd_hex(1:2))];
fwrite(ctrl_link,fdd_tdd_select,'uint8');
% trx_sw
trx_sw=[0 43 hex2dec('22') hex2dec('f0') hex2dec(trx_sw_hex(7:8)) hex2dec(trx_sw_hex(5:6)) hex2dec(trx_sw_hex(3:4)) hex2dec(trx_sw_hex(1:2))];
fwrite(ctrl_link,trx_sw,'uint8');
% aux_dac1
aux_dac1=[0 44 hex2dec('22') hex2dec('f0') hex2dec(aux_dac1_hex(7:8)) hex2dec(aux_dac1_hex(5:6)) hex2dec(aux_dac1_hex(3:4)) hex2dec(aux_dac1_hex(1:2))];
fwrite(ctrl_link,aux_dac1,'uint8');
%% send handshake cmd
handshake=[2 0 hex2dec('16') hex2dec('f0') 0 0 0 0];
fwrite(ctrl_link ,handshake, 'uint8');
%% send handshake2 cmd
data_length = dec2hex((2^(i-1)*2)*1024,8);
handshake=[2 0 hex2dec('17') hex2dec('f0') hex2dec(data_length(7:8)) hex2dec(data_length(5:6)) hex2dec(data_length(3:4)) hex2dec(data_length(1:2))];
fwrite(ctrl_link ,handshake, 'uint8');
%% Write data to the zing and read from the host.
fwrite(data_link,txd7,'uint8');
%% close all link
fclose(data_link);
delete(data_link);
clear data_link;
fclose(ctrl_link);
delete(ctrl_link);
clear ctrl_link;
ret='data send to yunsdr ok';
disp('data send to yunsdr ok');
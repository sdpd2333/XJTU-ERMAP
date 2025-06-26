clc;
warning off;
% a0=textread('E:\code\ieee802_11a\transmitter\dat\cmdcnt.dat');
% cmd_cor=corrcoef(a0,mysignal)
% a1=textread('E:\code\ieee802_11a\transmitter\dat\datacnt.dat');
% datacnt_cor=corrcoef(a1,data_bits)
% a2=textread('E:\code\ieee802_11a\transmitter\dat\scramble.dat');
% scramble_cor=corrcoef(a2,scramble_bits)
% a3=textread('E:\code\ieee802_11a\transmitter\dat\rsencode.dat');
% cmdrs_cor=corrcoef(a3(1:48),mysignala)
% datars_cor=corrcoef(a3(49:end),coded_bit_stream)
% a4=textread('E:\code\ieee802_11a\transmitter\dat\puncture.dat');
% cmdpunc_cor=corrcoef(a4(1:48),mysignala)
% datapunc_cor=corrcoef(a4(49:end),tx_bits)
% 
% [a5 a6]=textread('E:\code\ieee802_11a\transmitter\dat\mod_pilot.dat');
% a5_sig=a5-(a5>2047)*4096;
% a6_sig=a6-(a6>2047)*4096;
% mod_signal_cor=corrcoef(a5_sig(1:sim_options.upsample*64)+ ...
%     a6_sig(1:sim_options.upsample*64),mod_signal)
% mod_data_cor=corrcoef(a5_sig(sim_options.upsample*64+1:end)+ ...
%     1i*a6_sig(sim_options.upsample*64+1:end),mod_data)

% [a7 a8]=textread('E:\code\ieee802_11a\transmitter\dat\ifft.dat');
% a7_sig=a7-(a7>32767)*65536;
% a8_sig=a8-(a8>32767)*65536;
% iffta=(a7_sig+1i*a8_sig);
% ifft_signal_cor=corrcoef(iffta(1:sim_options.upsample*80),mysignalh)
% ifft_data_cor=corrcoef(iffta(sim_options.upsample*80+1:end),time_signal)

[a9 a10]=textread('E:\code\ieee802_11a\transmitter\dat\frameout.dat');
a9_sig=a9-(a9>32767)*65536;
a10_sig=a10-(a10>32767)*65536;
frame=(a9_sig+1i*a10_sig);
frame_cor=corrcoef(frame(length(tx_signal1)*0+1:1*length(tx_signal1)),tx_signal1)
a3=a9_sig;
a4=a10_sig;
% [a1,a2,a3,a4]=textread('E:\code\ieee802_11a\data\01.prn','%f%f%f%f','headerlines',1);
flt1=rcosine(1,2,'fir/sqrt',0.05,64);
E=rcosflt(a3+1i*a4, 1,2, 'filter', flt1);
a3=real(E);
a4=imag(E);
template=load('E:\code\micro_sdr\usb_test\mimo_convert\data\MIMOs1_msc7_162s3.mat');
d=(a3+1i*a4)./max([abs(a3);abs(a4)]);
info2=template.info2;
wavelp=template.wavelp;
wavelp.vsg.wave.data=d;
iqw_spec=template.iqw_spec;
wave=d;
save('E:\code\ieee802_11a\data\6mbps_4095.mat','info2','wavelp','iqw_spec','wave');




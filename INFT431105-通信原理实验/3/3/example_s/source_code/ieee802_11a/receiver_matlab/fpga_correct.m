clc;
warning off;
%% short frequency sync
% [a3 a4]=textread('E:\code\ieee802_11a\receiver\txt\freq_sync.dat');
% frsync=floor((a3+1i*a4)./2^22);
% frsyncm=rx_signal_coarse(1:length(frsync)).';
% freq_sync_short_cor=corrcoef(frsync,frsyncm)
%% long frequency sync
% [a7 a8]=textread('E:\code\ieee802_11a\receiver\txt\freq_sync_long.dat');
% frsync=floor((a7+1i*a8)./2^27);
% frsyncm=rx_signal_fine(1:length(frsync)).';
% freq_sync_long_cor=corrcoef(frsync,frsyncm)
%% rx_fft
% [a9 a10]=textread('E:\code\ieee802_11a\receiver\txt\rx_fft_tr.dat');
% rx_fft_tr=(a9+1i*a10)./2^2;
% rx_fft_tr_sym=reshape(rx_fft_tr,52,2);
% rx_fft_tr_cor=corrcoef(rx_fft_tr_sym,freq_tr_syms)
% [a11 a12]=textread('E:\code\ieee802_11a\receiver\txt\rx_fft_data.dat');
% rx_fft_data=(a11+1i*a12)./2^2;
% frame=floor(length(rx_fft_data)./52);
% rx_fft_data_sym=reshape(rx_fft_data(1:52*frame),52,frame);
% rx_fft_data_cor=corrcoef(rx_fft_data_sym,freq_data(:,1:frame))
%% rx_channel_est
% [a13 a14]=textread('E:\code\ieee802_11a\receiver\txt\data_eq.dat');
% data_eq=(a13+1i*a14);
% frame=floor(length(data_eq)./48);
% data_eq_sym=reshape(data_eq(1:48*frame),48,frame);
% data_eq_cor=corrcoef(data_eq_sym(:,1:frame),freq_data_syms(:,1:frame).*2^13)
% [a15 a16]=textread('E:\code\ieee802_11a\receiver\txt\pilot_eq.dat');
% pilot_eq=(a15+1i*a16);
% frame=floor(length(pilot_eq)./4);
% pilot_eq_sym=reshape(pilot_eq(1:4*frame),4,frame);
% pilot_eq_cor=corrcoef(pilot_eq_sym(:,1:frame),freq_pilot_syms(:,1:frame).*2^13)
%% phase tracker
[a17 a18]=textread('E:\code\ieee802_11a\receiver\txt\phase_tracker.dat');
data_pt=(a17+1i*a18);
frame1=floor(length(data_pt)./48);
frame2=size(freq_data_syms,2);
frame=min([frame1 frame2]);
% frame=11;
data_pt_sym=reshape(data_pt(1:48*frame),48,frame);
data_pt_cor=corrcoef(data_pt_sym(:,1:frame),freq_data_syms(:,1:frame).*2^31)





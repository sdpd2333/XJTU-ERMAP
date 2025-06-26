function [ output_args ] = ieee802_11b_rx_func( rxdata )

DEC_MET=3;

%% rx filter
fir = rcosdesign(1,128,4);
rx_signal_44 = upfirdn(rxdata,fir,1);
c1 = max([max(real(rx_signal_44)) max(imag(rx_signal_44))]);
rx_signal_44=rx_signal_44./c1;
%% rx sampling synchronization
[~, rx_downsamples] = rx_timing_recovery_11b(rx_signal_44.');
%% rx package search
[index_package,cor_abs]=rx_package_searck(rx_downsamples);
samples_package=rx_downsamples(index_package:end);
len=length(samples_package);
%% rx freq synchronization
%-----coarse freq synchronization-----%
seq_short_sync=samples_package(1:8*11);
[deltaf1,out_signal1]=rx_freq_sync(seq_short_sync,4,samples_package);
%-----fine freq synchronization-------%
seq_long_sync= out_signal1(1:128*11);
[deltaf2,out_signal2]= rx_freq_sync(seq_long_sync,2,out_signal1);
%% rx frame synchronization
[frame_type,frame_begin_index] = rx_frame_sync(out_signal2,DEC_MET);
index_start=1;
frame_data= out_signal2(index_start:end);
%% generate local sync signal
local_sync =rx_gen_local_sync(frame_type);
[deltaf3,out_signal3] = rx_freq_fine_sync(out_signal2,local_sync');
%% phase compensation
[sig_phase_syn,ang_offset] = rx_phase_sync(out_signal3,local_sync);
descramble_init=[1 1 0 1 1 0 0];
%% plcp info demod
info_plcp=rx_plcp_info(sig_phase_syn,frame_type);
sig_frame=sig_phase_syn(1:info_plcp.frame_index_end);
%% despread
sig_despread = despread(sig_frame,frame_type,info_plcp.data_rate);
sig_channel=sig_despread(10:73);
local_chan=local_sync(10:73).*exp(-1i*pi/4);

%% analyze PSDU
rx_psdu=sig_despread(193-info_plcp.pass:end);
[sig_psdu,crc_32,frame_err] = rx_psdu_info(rx_psdu,info_plcp.state,info_plcp.si,info_plcp.data_rate,frame_type);
%% ======================================================
%% display
%% ======================================================
h=figure(2);clf;
set(h,'name','IEEE 802.11b');
subplot(231);
plot(real(rxdata),'r');
hold on;
plot(imag(rxdata),'b');
title('rx original signal');
subplot(232);
pwelch(rxdata(1:info_plcp.frame_index_end*4),[],[],[],44e6,'centered','psd');
axis square;
subplot(234);
if ~isempty(strfind(frame_type, 'long'))
    plot(real(sig_despread(1:192)),imag(sig_despread(1:192)),'r*');
    hold on;
    plot(real(sig_despread(193:end)),imag(sig_despread(193:end)),'b.');
elseif ~isempty(strfind(frame_type, 'short'))
    plot(real(sig_despread(1:72)),imag(sig_despread(1:72)),'r*');
    hold on;
    plot(real(sig_despread(73:96)),imag(sig_despread(73:96)),'r*');
    hold on;
    plot(real(sig_despread(97:end)),imag(sig_despread(97:end)),'b.');
end
axis square;
axis([-1.2 1.2 -1.2 1.2]);
title('constellation diagram');
subplot(233);
line=cor_abs(index_package-78:index_package+98);
x_axis=(index_package-78:index_package+98);
plot(x_axis,line);
title('帧同步相关性曲线');
subplot(235);
axis off;
%     text(0.15,1.0,['cyc=', num2str(cyc,3)]);
%     text(0.15,1.0,['最佳采样点序号：',num2str(index_best,2)]);
text(0.15,0.9,['帧类型：',frame_type]);
text(0.15,0.8,['帧同步序号：',num2str(index_package,5)]);%,'FontSize',12
text(0.15,0.7,['频偏估计值：',num2str((deltaf1+deltaf2+deltaf3)/1e3,3),'KHz']);
text(0.15,0.6,['相位估计值：',num2str(ang_offset,3),'rad']);
text(0.15,0.5,['解扰器初值：', '[',num2str(descramble_init),']']);
text(0.15,0.4,['CRC\_16：', info_plcp.crc_16]);
text(0.15,0.3,['service：', '[',num2str(info_plcp.service),']']);
text(0.15,0.2,['数据速率：', num2str(info_plcp.data_rate,2),'Mbps']);
text(0.15,0.1,['调制模式：', info_plcp.mod_way]);
text(0.15,0.0,['数据长度：', num2str(info_plcp.data_length,4),'bytes']);
text(0.15,-0.1,['CRC\_32：', crc_32]);



end


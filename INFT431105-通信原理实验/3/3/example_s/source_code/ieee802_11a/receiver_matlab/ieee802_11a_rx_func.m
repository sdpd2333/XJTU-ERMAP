function [data_byte,sim_options] = ieee802_11a_rx_func(rx_signal_40,upsample)
sim_consts = set_sim_consts;
cyc=0;err_cyc=0;
viterbi='soft';
%% srrc
flt1=rcosine(1,upsample,'fir/sqrt',1,64);
rx_signal_40=rcosflt(rx_signal_40,1,1, 'filter', flt1);
rx_signal(:,1)=rx_signal_40(1:upsample:end);
%% Decimation
% rx_signal(:,1)=rx_signal_40(1:1:end);
%% srrc
% rx_signal1=round((rx_signal_40(1:end-1,:)+rx_signal_40(2:end,:))./2);
% rx_signal=[];
% rx_signal=rx_signal1(1:2:end,1); 
% if size(rx_signal1,2)==2
%    rx_signal2=rx_signal1(1:2:end,2); 
% end
while (1)
tic;
%% plot pwelch
figure(1);clf;
subplot(241);
plot(real(rx_signal(1:end)));hold on;plot(imag(rx_signal(1:end)));
title('原始信号时域波形');
subplot(242);
if size(rx_signal,1)>8
    pwelch(rx_signal,[],[],[],20e6,'centered','psd');
    title('原始信号功率谱密度');
else
    break;
end
%% packet search
[dc_offset,thres_idx] = rx_search_packet_short_fpga3(rx_signal);
disp(['thres_idx_short=',num2str(thres_idx)]);
if thres_idx>=length(rx_signal)-32
    break;
end
rx_signal_coarse_sync = rx_signal(thres_idx:end)-dc_offset;
subplot(243);
if size(rx_signal_coarse_sync,1)>400
    plot(abs(rx_signal_coarse_sync(1:220)));
    title('粗同步能量检测');
else
    break;
end
if thres_idx>60
    snr_est=20*log10(mean(abs(rx_signal(thres_idx+100:thres_idx+131)))) ...
        -20*log10(mean(abs(rx_signal(thres_idx-60:thres_idx-30))));
else
    snr_est=20*log10(mean(abs(rx_signal(thres_idx+thres_idx/2+1:thres_idx+thres_idx)))) ...
        -20*log10(mean(abs(rx_signal(thres_idx-thres_idx+1:thres_idx-thres_idx/2))));
end
%% short Frequency error estimation and correction
% [rx_signal_coarse, freq_est_short] = rx_frequency_sync_short2(rx_signal_coarse_sync);
rx_signal_coarse=rx_signal_coarse_sync;
freq_est_short=0;
%% Fine time synchronization
end_search=400;
thres_idx_fine = rx_search_packet_long(end_search,rx_signal_coarse);
if thres_idx_fine~=end_search
    rx_signal_fine_sync = rx_signal_coarse(thres_idx_fine+32:end);
else
    rx_signal=rx_signal_coarse(end_search:end);
    disp('short sync error');
    continue;
end
% [a7 a8]=textread('E:\code\ieee802_11a\receiver_v_vivado\txt\packet_search_long.dat');
% rx_signal_fine_sync=a7+1i*a8;
subplot(244);
if length(rx_signal_fine_sync)>320
    plot(abs(rx_signal_fine_sync(1:320)));
else
    plot(abs(rx_signal_fine_sync));
end
title('精同步信号时域波形');
disp(['sync_index=',num2str(thres_idx),'+',num2str(thres_idx_fine),'=',num2str(thres_idx+thres_idx_fine)]);
%% Frequency error estimation and correction
[rx_signal_fine, freq_est] = rx_frequency_sync_long(rx_signal_fine_sync);
% rx_signal_fine=rx_signal_fine_sync;
% [a77 a78]=textread('E:\code\ieee802_11a\receiver_v_vivado\txt\freq_sync_long.dat');
% rx_signal_fine=a77+1i*a78;
%% Return to frequency domain
[freq_tr_syms,  freq_data] = rx_timed_to_freqd(rx_signal_fine);
% [a9 a10]=textread('E:\code\ieee802_11a\receiver_v_vivado\txt\rx_fft_tr.dat');
% rx_fft_tr=(a9+1i*a10).*2^3;
% freq_tr_syms=reshape(rx_fft_tr,52,2);
% [a11 a12]=textread('E:\code\ieee802_11a\receiver_v_vivado\txt\rx_fft_data.dat');
% rx_fft_data=(a11+1i*a12).*2^3;
% frame=floor(length(rx_fft_data)./52);
% freq_data=reshape(rx_fft_data(1:52*frame),52,frame);
%% Channel estimation
channel_est = rx_estimate_channel(freq_tr_syms);
subplot(245);
plot([zeros(6,1);20*log10(abs(channel_est(1:26)));0;20*log10(abs(channel_est(27:52)));zeros(5,1)]);hold on;
title('信道估计图');
channel_est_data=repmat(channel_est,1,size(freq_data,2));
chan_data=freq_data.*conj(channel_est_data);
chan_data_amp=abs(channel_est_data(sim_consts.DataSubcPatt,:)).^2;
chan_data_syms=chan_data(sim_consts.DataSubcPatt,:);
chan_pilot_syms=chan_data(sim_consts.PilotSubcPatt,:);
% [a13 a14]=textread('E:\code\ieee802_11a\receiver_v_vivado\txt\data_eq.dat');
% data_eq=(a13+1i*a14);
% frame=floor(length(data_eq)./48);
% chan_data_syms=reshape(data_eq(1:48*frame),48,frame);
% [a15 a16]=textread('E:\code\ieee802_11a\receiver_v_vivado\txt\pilot_eq.dat');
% pilot_eq=(a15+1i*a16);
% chan_pilot_syms=reshape(pilot_eq(1:4*frame),4,frame);
% [abs2]=textread('E:\code\ieee802_11a\receiver_v_vivado\txt\abs2.dat');
% chan_data_amp=repmat(abs2(1:48),1,frame);
%% Phase tracker, returns phase error corrected symbols
[correction_phases,phase_error] = rx_pilot_phase_est1(chan_data_syms,chan_pilot_syms);
% correction_phases = rx_pilot_phase_est(chan_data_syms,chan_pilot_syms);
freq_data_syms = chan_data_syms.*exp(-1i.*correction_phases(sim_consts.DataSubcPatt,:));
% [a17 a18]=textread('E:\code\ieee802_11a\receiver_v_vivado\txt\phase_tracker.dat');
% data_pt=(a17+1i*a18);
% frame=floor(length(data_pt)./48);
% freq_data_syms=reshape(data_pt(1:48*frame),48,frame);
% [abs2]=textread('E:\code\ieee802_11a\receiver_v_vivado\txt\abs2.dat');
% chan_data_amp=repmat(abs2(1:48).*2^9,1,frame);
%% signal
%get the signal part
freq_signal_syms=freq_data_syms(:,1);
% Demodulate
[signal_soft_bits,evm_signal]=rx_demodulate_dynamic_soft(freq_signal_syms,chan_data_amp(:,1),'BPSK');
% Deinterleave 
signal_deint_bits = rx_deinterleave(signal_soft_bits,'BPSK');
% depuncture
[signal_depunc_bits,signal_erase] = rx_depuncture(signal_deint_bits,'R1/2');
% Vitervi decoding
t = poly2trellis(7, [133, 171]);
signal_bits = vitdec( signal_depunc_bits, t, 24, 'term', 'soft',3, ...
    [],signal_erase);
signal_bits=signal_bits(1:24);
%get RATE and LENGTH from signal_bits
[data_rate,data_length,signal_error]=rate_length(signal_bits);
if signal_error==1
    err_cyc=err_cyc+1;
    index_next=thres_idx+thres_idx_fine+1000;
    rx_signal=rx_signal(index_next:end);
    continue;
end
%get data parameters
sim_options=rx_get_data_parameter(data_rate,data_length);
%% calculate ofdm symbols
ofdm_symbol_num=ceil((16+sim_options.PacketLength.*8+6)/(sim_options.rate*4));
if ofdm_symbol_num+1>size(correction_phases,2)
    break;
end
subplot(246);
plot(phase_error(1,1:ofdm_symbol_num+1));
title('相位校正曲线');
%% data
subplot(247);
plot(real(freq_signal_syms)./chan_data_amp(:,1),imag(freq_signal_syms)./chan_data_amp(:,1),'*r');
hold on;
freq_data_syms_ser=reshape(freq_data_syms(:,2:ofdm_symbol_num+1),48*ofdm_symbol_num,1);
chan_data_amp_ser=reshape(chan_data_amp(:,2:ofdm_symbol_num+1),48*ofdm_symbol_num,1);
plot(real(freq_data_syms_ser)./chan_data_amp_ser,imag(freq_data_syms_ser)./chan_data_amp_ser,'.');
axis([-1.5,1.5,-1.5,1.5]);
title('相位补偿后星座图');
% Demodulate
[data_soft_bits,evm_data]=rx_demodulate_dynamic_soft ...
    (freq_data_syms_ser,chan_data_amp_ser,sim_options.Modulation);
% Deinterleave 
data_deint_bits = rx_deinterleave(data_soft_bits,sim_options.Modulation);
% depuncture
[data_depunc_bits,data_erase] = rx_depuncture(data_deint_bits,sim_options.ConvCodeRate);
% Viterbi decoding
if ~isempty(findstr(viterbi, 'soft'))
    data_descramble_bits = vitdec( data_depunc_bits(1:(16+sim_options.PacketLength*8+6)*2), t, 96, 'term', 'soft',3, ...
        [],data_erase(1:(16+sim_options.PacketLength*8+6)*2));
else
    data_depunc_bits=data_depunc_bits>=4;
    data_descramble_bits = vitdec( data_depunc_bits, t, 48, 'term', 'hard', ...
        [],data_erase);
end
%desramble
[scramble,data_bits]=rx_descramble(data_descramble_bits);
%remove pad
service_bits=data_bits(1:16);
inf_bits=data_bits(16+1:16+sim_options.PacketLength*8);
bits=inf_bits(1:length(inf_bits)-32);
bits_r=reshape(bits,8,length(bits)/8).';
data_byte=bi2de(bits_r,'left-msb');
%use crc to detect the "receiving" inf_bits
ret=crc32_new(inf_bits(1:length(inf_bits)-32)).';
crc_bits=inf_bits(length(inf_bits)-31:length(inf_bits));
crc_outputs=sum(xor(ret,crc_bits),2);
if crc_outputs==0
    crc_ok='YES';
    cyc=cyc+1;
    evm(cyc)=evm_data;
    freq_khz(cyc)=(freq_est+freq_est_short)/1e3;
else
    crc_ok='NO';
    err_cyc=err_cyc+1;
end
disp(['crc32=',crc_ok]);
[uV sV] = memory;
time=toc;
mem=round(uV.MemUsedMATLAB/2^20);
subplot(248);
axis off;
text(0.1,0.9,['粗同步序号',num2str(thres_idx),';精同步序号',num2str(thres_idx_fine)]);
text(0.1,0.8,['频偏估计值',num2str((freq_est+freq_est_short)/1e3,3),'KHz']);
text(0.1,0.7,['加扰器',num2str(scramble)]);
text(0.1,0.6,['service',num2str(service_bits)]);
text(0.1,0.5,['码速率',num2str(sim_options.rate),'Mbps,','调制模式',sim_options.Modulation]);
text(0.1,0.4,['数据长度 ',num2str(sim_options.PacketLength),'byte ,',num2str(ofdm_symbol_num),'ofdms']);
text(0.1,0.3,['data解调信息,crc是否通过:',crc_ok]);
text(0.1,0.2,['signal星座图EVM:',num2str(evm_signal*100,2),'%,',num2str(20*log10(evm_signal),3),'dB']);
text(0.1,0.1,['data星座图EVM:',num2str(evm_data*100,2),'%,',num2str(20*log10(evm_data),3),'dB']);
text(0.1,0.0,['信噪比S/N估计值:',num2str(snr_est,4),'dB']);
title(['crc ok=',num2str(cyc),';crc err=',num2str(err_cyc),';mem=',num2str(mem),'MB',';FPS=',num2str(1/time)]);
%% calculate next frame
index_next=thres_idx+thres_idx_fine+160+80*(ofdm_symbol_num+1);
if length(rx_signal)-index_next>1000
    rx_signal=rx_signal(index_next:end);
else
    break;
end 
pause(0.2);
break;
end
disp(['正确帧数',num2str(cyc),' frame']);
disp(['错误帧数',num2str(err_cyc),' frame']);
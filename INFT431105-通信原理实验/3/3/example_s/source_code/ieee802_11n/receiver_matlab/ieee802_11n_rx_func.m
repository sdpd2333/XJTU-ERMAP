function [data_byte,sim_options] = ieee802_11n_rx_func(rx_signal_40,upsample)
sim_consts = set_sim_consts;
cyc=0;err_cyc=0;
viterbi='soft';
%% srrc
flt1=rcosine(1,upsample,'fir/sqrt',1,64);
rx_signal_40=rcosflt(rx_signal_40,1,1, 'filter', flt1);
rx_signal=rx_signal_40(1:upsample:end,:);
%% Decimation
% rx_signal=rx_signal_40(1:2:end,:);
%% srrc
% rx_signal1=round((rx_signal_40(1:end-1,:)+rx_signal_40(2:end,:))./2);
% rx_signal=[];
% rx_signal=rx_signal1(1:2:end,:); 
%% plot pwelch
while(1)
tic;
figure(1);clf;
set(gcf,'name','IEEE802.11n接收端物理层演示');
subplot(241);
for i=1:size(rx_signal,2)
    plot(real(rx_signal(:,i)));hold on
end
title('原始信号时域波形');
hold off
subplot(242);
if size(rx_signal,1)>8
    pwelch(rx_signal,[],[],[],20e6,'centered','psd');
    title('原始信号功率谱密度');
else
    break;
end
%% packet search
[dc_offset,thres_idx] = rx_search_packet_short_fpga3(rx_signal(:,1));
if thres_idx>=size(rx_signal,1)-32
    break;
end
rx_signal_coarse_sync = rx_signal(thres_idx:end,:)-dc_offset;
subplot(243);
if size(rx_signal_coarse_sync,1)>400
    plot(abs(rx_signal_coarse_sync(1:220,1)));
    title('粗同步能量检测');
else
    break;
end
%% fine packet search
end_search=400;
thres_idx_long = rx_search_packet_long(end_search,rx_signal_coarse_sync);
if thres_idx_long~=end_search
    Nrx=size(rx_signal_coarse_sync,2);
    Ns=size(rx_signal_coarse_sync,1);
    rx_signal_fine_sync=zeros(Ns,Nrx);
    for i=1:Nrx
        rx_signal_fine_sync(1:end-thres_idx_long(i)-31,i) = rx_signal_coarse_sync(thres_idx_long(i)+32:end,i);
    end
else
    rx_signal=rx_signal_coarse_sync(end_search:end,:);
    disp('short sync error');
    continue;
end
subplot(244);
plot(abs(rx_signal_fine_sync(1:320)));
title('精同步信号时域波形');
disp(['sync_index=',num2str(thres_idx),'+',num2str(thres_idx_long),'=',num2str(thres_idx+thres_idx_long)]);
%% Frequency error estimation and correction
[rx_signal_fine, freq_est] = rx_frequency_sync(rx_signal_fine_sync);
%% legacy Return to frequency domain
[freq_legacy_ltf,freq_legacy_sig,freq_highthrough_sig] = rx_timed_to_freqd_legacy(rx_signal_fine);
%% legacy Channel estimation
channel_est=rx_estimate_channel_legacy(freq_legacy_ltf);
freq_legacy_sig=freq_legacy_sig./channel_est;
freq_highthrough_sig=freq_highthrough_sig./repmat(channel_est,2,1);
if Nrx~=1
    freq_legacy_sig_mean=mean(freq_legacy_sig.').';
    freq_highthrough_sig_mean=mean(freq_highthrough_sig.').';
else
    freq_legacy_sig_mean=freq_legacy_sig;
    freq_highthrough_sig_mean=freq_highthrough_sig;
end
subplot(245);
for i=1:Nrx
    plot(20*log10(abs(channel_est(:,i))));hold on
end
title('legacy信道估计图');
hold off
%% signal Phase correction
legacy_sig_pc=rx_pilot_phase_signal(freq_legacy_sig_mean);
highthrough_sig_pc=rx_pilot_phase_signal(freq_highthrough_sig_mean);
%% decode legacy signal
% Demodulate
[lsig_soft_bits,evm_lsig]=rx_demodulate_dynamic_soft(legacy_sig_pc,ones(size(legacy_sig_pc)),'BPSK');
% Deinterleave 
lsig_deint_bits=rx_deinterleave(lsig_soft_bits,sim_consts.nonHTNumDataSubc,1);
% Viterbi decoding
t = poly2trellis(7, [133, 171]);
lsig_bits = vitdec( [lsig_deint_bits,zeros(1,48)], t, 48, 'term', 'soft',3);
lsig_bits=lsig_bits(1:24);
[l_rate,l_length,lsig_error]=lsig_rate_length(lsig_bits);
if lsig_error==1
    err_cyc=err_cyc+1;
    index_next=thres_idx+max(thres_idx_long)+1000;
    rx_signal=rx_signal(index_next:end,:);
    continue;
end
%% decode highthrough signal
% Demodulate
[hsig_soft_bits,evm_hsig]=rx_demodulate_dynamic_soft(-1i*highthrough_sig_pc,ones(size(highthrough_sig_pc)),'BPSK');
% Deinterleave 
hsig_deint_bits=rx_deinterleave(hsig_soft_bits,sim_consts.nonHTNumDataSubc,1);
% Viterbi decoding
hsig_bits = vitdec( hsig_deint_bits, t, 48, 'term', 'soft',3);
[sim_options,hsig_error]=hsig_rate_length(hsig_bits);
if hsig_error==1
    err_cyc=err_cyc+1;
    index_next=thres_idx+max(thres_idx_long)+1000;
    rx_signal=rx_signal(index_next:end,:);
    continue;
end
%% spilt stf,ltf,data
if 368+80+80*sim_options.Nss+80*sim_options.Nsym>size(rx_signal_fine,1)
    break;
end
h_stf=rx_signal_fine(369:368+80,:);
switch sim_options.Nss
    case{1}
        h_ltf=rx_signal_fine(368+80+1:368+80+80,:);
        h_data=rx_signal_fine(368+80+80+1:368+80+80+80*sim_options.Nsym,:);
    case{2}
        h_ltf=rx_signal_fine(368+80+1:368+80+80*2,:);
        h_data=rx_signal_fine(368+80+80*2+1:368+80+80*2+80*sim_options.Nsym,:);
    case{3,4}
        h_ltf=rx_signal_fine(368+80+1:368+80+80*4,:);
        h_data=rx_signal_fine(368+80+80*4+1:368+80+80*4+80*sim_options.Nsym,:);
end
%% Return to frequency domain
freq_h_ltf = rx_timed_to_freqd(h_ltf);
freq_h_data = rx_timed_to_freqd(h_data);
%% highthrough Channel estimation
h_est=rx_estimate_channel_highthrough(freq_h_ltf);
for j=0:sim_options.Nsym-1
    for i=1:56
        row=[0:sim_options.Nss-1].*56+i;
        data_eq(j*56+i,:)=h_est(row,:)^-1*freq_h_data(j*56+i,:).';
    end
end
%% highthrough Phase correction
[data_pc,phase_error_degree]=rx_pilot_phase(data_eq);
subplot(246);
for i=1:sim_options.Nss
    plot(phase_error_degree(:,i));hold on
end
title('剩余载波误差角度');
hold off
subplot(247);
for i=1:sim_options.Nss
    plot(real(data_pc(:,i)),imag(data_pc(:,i)),'.');
    axis([-1.5,1.5,-1.5,1.5]);hold on
end
title('信道均衡和剩余载波消除后星座图');
hold off
%% decode highthrough data
% Demodulate
for i=1:sim_options.Nss
    [data_soft_bits(:,i),evm_data(:,i)]=rx_demodulate_dynamic_soft ...
        (data_pc(:,i),ones(size(data_pc(:,i))),sim_options.Modulation);
end
% Deinterleave 
rx_delv = rx_deinterleaver_ht(data_soft_bits,sim_options);
% parser
rx_parser=rx_stream_parser(rx_delv,sim_options);
% depuncture
[rx_depunc,data_erase] = rx_depuncture(rx_parser,sim_options.ConvCodeRate);
% Viterbi decoding
rx_decode = vitdec( rx_depunc, t, 48, 'term', 'soft',3, ...
        [],data_erase);
% rx_decode = rx_viterbi_decode(rx_depunc,sim_options.ConvCodeRate);
%desramble
[scramble,data_bits]=rx_descramble(rx_decode);
%remove pad
service_bits=data_bits(1:16);
inf_bits=data_bits(16+1:16+sim_options.PacketLength*8);
bits=inf_bits(1:length(inf_bits)-32);
bits_r=reshape(bits,8,length(bits)/8).';
data_byte=bi2de(bits_r,'left-msb');
%use crc to detect the "receiving" inf_bits
ret=crc32_new(inf_bits(1:length(inf_bits)-32)).';
crc_bits=inf_bits(length(inf_bits)-31:end);
crc_outputs=sum(xor(ret,crc_bits),2);
if crc_outputs==0
    crc_ok='YES';
    cyc=cyc+1;
    evm(cyc,:)=evm_data;
else
    crc_ok='NO';
    err_cyc=err_cyc+1;
end
disp(['crc32=',crc_ok]);
%% calc memory and time
[uV sV] = memory;
time=toc;
mem=round(uV.MemUsedMATLAB/2^20);
%% plot
subplot(248);
axis off;
text(0.1,0.9,['粗同步序号',num2str(thres_idx),';精同步序号',num2str(thres_idx_long)]);
text(0.1,0.8,['频偏估计值(KHz)',num2str((freq_est)/1e3,3)]);
text(0.1,0.7,['service',num2str(service_bits),';加扰器',num2str(scramble)]);
text(0.1,0.6,['加扰器',num2str(scramble)]);
text(0.1,0.5,['MCS',num2str(sim_options.mcs),',',sim_options.Modulation,',RATE=',num2str(sim_options.ConvCodeRate)]);
text(0.1,0.4,['码速率',num2str(sim_options.Ndbps./4),'Mbps,','天线数',num2str(sim_options.Nss)]);
text(0.1,0.3,['数据长度 ',num2str(sim_options.PacketLength),'byte ,',num2str(sim_options.Nsym),'ofdms']);
text(0.1,0.2,['data解调信息,crc是否通过:',crc_ok]);
text(0.1,0.1,['data星座图EVM(%):',num2str(evm_data*100,2)]);
text(0.1,0.0,['data星座图EVM(dB):',num2str(20*log10(evm_data),3)]);
title(['cyc ok=',num2str(cyc),';cyc err=',num2str(err_cyc),';mem=',num2str(mem),'MB',';FPS=',num2str(1/time)]);
%% calculate next frame
index_next=thres_idx+max(thres_idx_long)+160+80+160+80+80*sim_options.Nss+80*sim_options.Nsym+10;
if size(rx_signal,1)-index_next>1000
    rx_signal=rx_signal(index_next:end,:);
else
    break;
end 
pause(0.1);
break;
end
disp(['正确帧数',num2str(cyc),' frame']);
disp(['错误帧数',num2str(err_cyc),' frame']);
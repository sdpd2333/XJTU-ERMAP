%跳频通信  接收端  20201205 pluto竞赛
%作者：cuier
clearvars -except times;close all;warning off;
set(0,'defaultfigurecolor','w');
addpath ..\library
addpath ..\library\matlab

ip = '192.168.2.1';
addpath BPSK/transmitter
addpath BPSK/receiver

Hop_bits_number = 2500;
Jump_f_number = 5;
Jump_f = [0:200e3:800e3];

% train sequence----127 bits
seq_sync = tx_gen_m_seq([1 0 0 0 0 0 1]);
local_sync = tx_modulate(seq_sync, 'BPSK');

%% Transmit and Receive using MATLAB libiio

% System Object Configuration
s = iio_sys_obj_matlab; % MATLAB libiio Constructor
s.ip_address = ip;
s.dev_name = 'ad9361';
s.in_ch_no = 2;
s.out_ch_no = 2;
s.in_ch_size = Hop_bits_number*Jump_f_number;
s.out_ch_size = Hop_bits_number*Jump_f_number*8;

s = s.setupImpl();

input = cell(1, s.in_ch_no + length(s.iio_dev_cfg.cfg_ch));
output = cell(1, s.out_ch_no + length(s.iio_dev_cfg.mon_ch));

% 接收设置-----
input{s.getInChannel('RX_LO_FREQ')} = 433.920e9;  %与发送端的发送频点一致
input{s.getInChannel('RX_SAMPLING_FREQ')} = 10e6;
input{s.getInChannel('RX_RF_BANDWIDTH')} = 5e6;
input{s.getInChannel('RX1_GAIN_MODE')} = 'manual';%% slow_attack manual
input{s.getInChannel('RX1_GAIN')} = 10;
% input{s.getInChannel('RX2_GAIN_MODE')} = 'slow_attack';
% input{s.getInChannel('RX2_GAIN')} = 0;
%发送设置-------不需要，但为了程序的完整性  保留
input{s.getInChannel('TX_LO_FREQ')} = 2e9;
input{s.getInChannel('TX_SAMPLING_FREQ')} = 10e6;
input{s.getInChannel('TX_RF_BANDWIDTH')} = 5e6;


for i=1:20

    output = stepImpl_receive(s, input);  %可以将此函数改为只有接收

    I = output{1};
    Q = output{2};
    Rx = I+1i*Q;
    
    %----------------解跳频------------------------------%
    %% matched filtering
     fir = rcosdesign(1,128,4);
     rx_sig_filter = upfirdn(Rx,fir,1);
     
     %% normalization
      c1=max([abs(real(rx_sig_filter.')),abs(imag(rx_sig_filter.'))]);
      rx_sig_norm=rx_sig_filter ./c1;
      
     %% sampling synchronization
      [time_error,rx_sig_down]=rx_timing_recovery(rx_sig_norm.');


end


s.releaseImpl();




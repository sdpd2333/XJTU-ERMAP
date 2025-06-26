%跳频通信  发送端  20201203 pluto竞赛
%作者：cuier

clearvars -except times;close all;warning off;
addpath ..\library
addpath ..\library\matlab
addpath BPSK/transmitter

ip = '192.168.2.1';

%% --------------------------------生成跳频要发送的序列-----------------------------------
% train sequence----127 bits

seq_sync=tx_gen_m_seq([1 0 0 0 0 0 1]);
sync_symbols=tx_modulate(seq_sync, 'BPSK');

%% message 2047 bits, 用11阶的M序列产生
seq_mst = tx_gen_m_seq([1 0 1 0 0 0 0 0 0 0 0]);

% %% scramble-----如果用M序列作为信息位则不需要加扰，如果是传输音频文件 则需要加扰
% scramble_int=[1,1,0,1,1,0,0];
% sym_bits=scramble(scramble_int, seq_bit);
%% modulate
mod_symbols=tx_modulate(seq_bit, 'BPSK');
trans_symbols=[sync_symbols mod_symbols];

%添加一个将2047+127 补零补到2500bits

%% srrc  成型滤波 将200K采样率的2500bits内插50倍（采样率变到了10M），然后经过成型滤波
fir=rcosdesign(1,128,4);
tx_frame=upfirdn(trans_symbols,fir,4);
%tx_frame=[tx_frame, zeros(1, ceil(length(tx_frame)/2))];
%txdata = tx_frame.';

%跳频 
%跳频为5个频点： 433.920M+0，433.920M+200K、433.920M+400K、433.920M+600K、433.920M+800K
%在10MHz采样率下，500*50bits为一跳
jump_f = [0:200e3:800e3];
fs = 10e6;
Hop_bits_number = 2500;
jump1 = exp(1j * 2*pi * jump_f./fs * [0:2499]);
%把txdata变成5行2500列
txdata = jump1.*txdata;


%% display
plot(real(tx_frame));
hold on
plot(imag(tx_frame));

txdata = round(txdata .* 2^14); 
%% Transmit and Receive using MATLAB libiio
% System Object Configuration
s = iio_sys_obj_matlab; % MATLAB libiio Constructor
s.ip_address = ip;
s.dev_name = 'ad9361';
s.in_ch_no = 2;
s.out_ch_no = 2;
s.in_ch_size = length(txdata);
%s.out_ch_size = length(txdata).*16;

s = s.setupImpl();

input = cell(1, s.in_ch_no + length(s.iio_dev_cfg.cfg_ch));
output = cell(1, s.out_ch_no + length(s.iio_dev_cfg.mon_ch));

% Set the attributes of
% AD9363----------------发送端的接收相关可以不配置，但是为了完整性以及避免预料不到的错误，这些设置保留。
input{s.getInChannel('RX_LO_FREQ')} = 1.45e9;
input{s.getInChannel('RX_SAMPLING_FREQ')} = 10e6;
input{s.getInChannel('RX_RF_BANDWIDTH')} = 5e6;
input{s.getInChannel('RX1_GAIN_MODE')} = 'manual';
input{s.getInChannel('RX1_GAIN')} = 2;
% input{s.getInChannel('RX2_GAIN_MODE')} = 'slow_attack';
% input{s.getInChannel('RX2_GAIN')} = 0;

%------发送的频点
input{s.getInChannel('TX_LO_FREQ')} = 433.920e6;  %跳频的中心频率
input{s.getInChannel('TX_SAMPLING_FREQ')} = 10e6; %采样率10MHz
input{s.getInChannel('TX_RF_BANDWIDTH')} = 5e6; %采样带宽5MHz


for i=1:10
    input{1} = real(txdata);
    input{2} = imag(txdata);
    output = stepImpl(s, input);
end


s.releaseImpl();




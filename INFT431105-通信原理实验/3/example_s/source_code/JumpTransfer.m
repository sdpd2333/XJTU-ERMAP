%��Ƶͨ��  ���Ͷ�  20201203 pluto����
%���ߣ�cuier

clearvars -except times;close all;warning off;
addpath ..\library
addpath ..\library\matlab
addpath BPSK/transmitter

ip = '192.168.2.1';

%% --------------------------------������ƵҪ���͵�����-----------------------------------
% train sequence----127 bits

seq_sync=tx_gen_m_seq([1 0 0 0 0 0 1]);
sync_symbols=tx_modulate(seq_sync, 'BPSK');

%% message 2047 bits, ��11�׵�M���в���
seq_mst = tx_gen_m_seq([1 0 1 0 0 0 0 0 0 0 0]);

% %% scramble-----�����M������Ϊ��Ϣλ����Ҫ���ţ�����Ǵ�����Ƶ�ļ� ����Ҫ����
% scramble_int=[1,1,0,1,1,0,0];
% sym_bits=scramble(scramble_int, seq_bit);
%% modulate
mod_symbols=tx_modulate(seq_bit, 'BPSK');
trans_symbols=[sync_symbols mod_symbols];

%���һ����2047+127 ���㲹��2500bits

%% srrc  �����˲� ��200K�����ʵ�2500bits�ڲ�50���������ʱ䵽��10M����Ȼ�󾭹������˲�
fir=rcosdesign(1,128,4);
tx_frame=upfirdn(trans_symbols,fir,4);
%tx_frame=[tx_frame, zeros(1, ceil(length(tx_frame)/2))];
%txdata = tx_frame.';

%��Ƶ 
%��ƵΪ5��Ƶ�㣺 433.920M+0��433.920M+200K��433.920M+400K��433.920M+600K��433.920M+800K
%��10MHz�������£�500*50bitsΪһ��
jump_f = [0:200e3:800e3];
fs = 10e6;
Hop_bits_number = 2500;
jump1 = exp(1j * 2*pi * jump_f./fs * [0:2499]);
%��txdata���5��2500��
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
% AD9363----------------���Ͷ˵Ľ�����ؿ��Բ����ã�����Ϊ���������Լ�����Ԥ�ϲ����Ĵ�����Щ���ñ�����
input{s.getInChannel('RX_LO_FREQ')} = 1.45e9;
input{s.getInChannel('RX_SAMPLING_FREQ')} = 10e6;
input{s.getInChannel('RX_RF_BANDWIDTH')} = 5e6;
input{s.getInChannel('RX1_GAIN_MODE')} = 'manual';
input{s.getInChannel('RX1_GAIN')} = 2;
% input{s.getInChannel('RX2_GAIN_MODE')} = 'slow_attack';
% input{s.getInChannel('RX2_GAIN')} = 0;

%------���͵�Ƶ��
input{s.getInChannel('TX_LO_FREQ')} = 433.920e6;  %��Ƶ������Ƶ��
input{s.getInChannel('TX_SAMPLING_FREQ')} = 10e6; %������10MHz
input{s.getInChannel('TX_RF_BANDWIDTH')} = 5e6; %��������5MHz


for i=1:10
    input{1} = real(txdata);
    input{2} = imag(txdata);
    output = stepImpl(s, input);
end


s.releaseImpl();




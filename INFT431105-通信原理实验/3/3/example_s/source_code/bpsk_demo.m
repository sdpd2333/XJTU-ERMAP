clearvars -except times;close all;warning off;
set(0,'defaultfigurecolor','w');
addpath ..\library
addpath ..\library\matlab

ip = '192.168.2.1';
addpath 2FSK
addpath 2FSK
addpath 16QAM\receiver
addpath 16QAM\transmitter
% txdata = fsk2_tx_func(20);
txdata = qpsk_tx_func;
% txdata = qam16_tx_func;
% txdata = psk2_tx_func(20);
txdata = round(txdata .* 2^14);% 只去掉这个就传输不成功
% txdata = repmat(txdata, 4,1);

%% Transmit and Receive using MATLAB libiio

% System Object Configuration
s = iio_sys_obj_matlab; % MATLAB libiio Constructor
s.ip_address = ip;
s.dev_name = 'ad9361';
s.in_ch_no = 2;
s.out_ch_no = 2;
s.in_ch_size = length(txdata);
s.out_ch_size = length(txdata).*8;
% s.out_ch_size = 5e4;

s = s.setupImpl();

input = cell(1, s.in_ch_no + length(s.iio_dev_cfg.cfg_ch));
output = cell(1, s.out_ch_no + length(s.iio_dev_cfg.mon_ch));
%%
% Set the attributes of AD9361
input{s.getInChannel('RX_LO_FREQ')} = 2e9;
input{s.getInChannel('RX_SAMPLING_FREQ')} = 40e6;
input{s.getInChannel('RX_RF_BANDWIDTH')} = 20e6;
input{s.getInChannel('RX1_GAIN_MODE')} = 'manual';%% slow_attack manual
input{s.getInChannel('RX1_GAIN')} = 1;
% input{s.getInChannel('RX1_GAIN_MODE')} = 'slow_attack';%% slow_attack manual
% % input{s.getInChannel('RX1_GAIN')} = 1;

% input{s.getInChannel('RX2_GAIN_MODE')} = 'slow_attack';
% input{s.getInChannel('RX2_GAIN')} = 0;
input{s.getInChannel('TX_LO_FREQ')} = 2e9;
input{s.getInChannel('TX_SAMPLING_FREQ')} = 40e6;
input{s.getInChannel('TX_RF_BANDWIDTH')} = 20e6;

% while(1)
for i=1:30%一般要在第5次后才能正确接收，前面可能信号还没传输过去
    
    
    fprintf('Transmitting Data Block %i ...\n',i);
    input{1} = real(txdata);
    input{2} = imag(txdata);
    output = stepImpl(s, input);
    fprintf('Data Block %i Received...\n',i);
    I = output{1};
    Q = output{2};
    Rx = I+1i*Q;
%     freq = qpsk_rx_func(Rx);
    if i>=10
        freq = my_rx_func(Rx);
        if freq~=0
            fprintf('The freq offset = %fHz\n', freq)
        end
    end
    pause(0.1);
end
% while(1)
%     input{1} = real(txdata);
%     input{2} = imag(txdata);
%     output = stepImpl(s, input);
%     %fprintf('Data Block %i Received...\n',i);
%     I = output{1};
%     Q = output{2};
%     Rx = I+1i*Q;
% %     qam16_rx_func(Rx(end/2:end));
%     % fsk2_rx_func(Rx(end/2:end));
%     pause(0.1);
%     fprintf('Trans...\n');
% end

fprintf('Transmission and reception finished\n');
% mean(flist)
% Read the RSSI attributes of both channels
rssi1 = output{s.getOutChannel('RX1_RSSI')};
% rssi2 = output{s.getOutChannel('RX2_RSSI')};

s.releaseImpl();




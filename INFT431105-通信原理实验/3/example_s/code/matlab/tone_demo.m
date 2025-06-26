clearvars -except times;close all;warning off;

addpath ..\..\library
addpath ..\..\library\matlab

ip = '192.168.2.1';
a=cos(2*pi/32*[0:31].');
b=sin(2*pi/32*[0:31].');
c=a+1i*b;
txdata = repmat(c, 4096, 1);
txdata = round(txdata .* 2^15); 


%% Transmit and Receive using MATLAB libiio

% System Object Configuration
s = iio_sys_obj_matlab; % MATLAB libiio Constructor
s.ip_address = ip;
s.dev_name = 'ad9361';
s.in_ch_no = 2;
s.out_ch_no = 2;
s.in_ch_size = length(txdata);
s.out_ch_size = length(txdata).*16;

s = s.setupImpl();

input = cell(1, s.in_ch_no + length(s.iio_dev_cfg.cfg_ch));
output = cell(1, s.out_ch_no + length(s.iio_dev_cfg.mon_ch));

% Set the attributes of AD9361
input{s.getInChannel('RX_LO_FREQ')} = 1.45e9;
input{s.getInChannel('RX_SAMPLING_FREQ')} = 40e6;
input{s.getInChannel('RX_RF_BANDWIDTH')} = 20e6;
input{s.getInChannel('RX1_GAIN_MODE')} = 'manual';
input{s.getInChannel('RX1_GAIN')} = 2;
% input{s.getInChannel('RX2_GAIN_MODE')} = 'slow_attack';
% input{s.getInChannel('RX2_GAIN')} = 0;
input{s.getInChannel('TX_LO_FREQ')} = 1.45e9;
input{s.getInChannel('TX_SAMPLING_FREQ')} = 40e6;
input{s.getInChannel('TX_RF_BANDWIDTH')} = 20e6;


for i=1:4
    fprintf('Transmitting Data Block %i ...\n',i);
    input{1} = real(txdata);
    input{2} = imag(txdata);
    output = stepImpl(s, input);
end
fprintf('Transmission and reception finished\n');
    I = output{1};
    Q = output{2};
    Rx = I+1i*Q;
    figure(1); clf;
    subplot(131);
    plot(I);
    hold on;
    plot(Q);
    subplot(132);
    plot(I, Q, 'b');
    axis square;
    subplot(133);
    pwelch(Rx, [],[],[], 40e6, 'centered', 'psd');
% Read the RSSI attributes of both channels
rssi1 = output{s.getOutChannel('RX1_RSSI')};
% rssi2 = output{s.getOutChannel('RX2_RSSI')};

s.releaseImpl();




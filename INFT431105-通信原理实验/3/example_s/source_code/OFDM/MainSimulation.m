clear;clc;close all;

% Setting parameters
NumFFT = 128;
NumSyncPreamble = 32;
NumCP = 16;
SNRdB = 20; % dB
NumPreTxSignal = 100;
NumPostTxSignal = 100;

NumDataOfdmSymb = 18;
NumDataSubcarrier = 108;

%% Start transmitter
Transmitter;
% tmp;
% TxSignal=rx_signal(1:4:end);
%% Pass AWGN channel
TxSignalExt = [ ...
    zeros(NumPreTxSignal, 1); ...
    TxSignal; ...
    zeros(NumPostTxSignal, 1)];
% Snr = 10.^(SNRdB/10);
% PowTxSignal = mean(abs(TxSignal).^2);
% PowNoise = PowTxSignal / Snr;
% Noise = sqrt(PowNoise) * (randn(size(TxSignalExt)) + 1j*randn(size(TxSignalExt)));
% RxSignalExt = TxSignalExt + Noise;
RxSignalExt=add_user_channel(TxSignalExt,0e3,20,1);
kmh=0;
fd=2400e6/3e8*kmh/3.6;
c1 = rayleighchan(1/1.4e6,fd);
c1.PathDelays = [0 600e-9 900e-9];
c1.AvgPathGaindB=[0 -10 -10];
% RxSignalExt = filter(c1,RxSignalExt);
%% Start receiver
Receiver;

%% Calculate bit error rate
NumErrorBits = sum(sum(RxDataBits ~= TxDataBits));
BitErrorRate = NumErrorBits / numel(TxDataBits);

fprintf('Bit error rate (BER): %d \n', BitErrorRate);

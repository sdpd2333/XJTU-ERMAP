% 比较 2T1R / 2T2R 的 QPSK、8QAM、16QAM 误码率。
% 先运行 tiaozhi_diffrence.m 和 doubleRX.m 可重新生成所需数据。
data_dir = fileparts(mfilename('fullpath'));
filenames = {'data_singleRX_QPSK.mat', 'data_singleRX_8QAM.mat', ...
    'data_singleRX_16QAM.mat', 'data_doubleRX_QPSK.mat', ...
    'data_doubleRX_8QAM.mat', 'data_doubleRX_16QAM.mat'};
preferred_fields = {'ber1', 'ber2', 'ber3', 'ber1', 'ber1', 'ber1'};
curves = cell(1, numel(filenames));
for index = 1:numel(filenames)
    [snr_axis, curves{index}] = load_ber_curve( ...
        fullfile(data_dir, filenames{index}), preferred_fields{index});
    if index == 1
        EsN0 = snr_axis;
    elseif ~isequal(EsN0, snr_axis)
        error('ERMAP:SNRMismatch', 'SNR grid differs in %s.', filenames{index});
    end
end
figure;
semilogy(EsN0, curves{1}, '-ro', EsN0, curves{2}, '-b*', ...
    EsN0, curves{3}, '-k+', EsN0, curves{4}, '--ro', ...
    EsN0, curves{5}, '--b*', EsN0, curves{6}, '--k+');
grid on;
legend('QPSK2T1R', '8QAM2T1R', '16QAM2T1R', 'QPSK2T2R', '8QAM2T2R', '16QAM2T2R');
xlabel('信噪比 Es/N0');
ylabel('误比特率（BER）');
title('Alamouti 方案在准静态瑞利衰落信道下的误码率性能');

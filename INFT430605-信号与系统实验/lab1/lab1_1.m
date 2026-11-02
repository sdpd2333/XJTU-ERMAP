% 直接求和分析音频频谱；先将 samples 中的音频目录加入 MATLAB 路径。
[y, fs] = audioread('7noise.wav');
y = mean(y, 2); % 多声道输入转为单声道。
Q = 10000; % 频率网格点数。
w = linspace(-pi, pi, Q);
h = direct_spectrum(y, w, 40000); % 最多使用 40000 个样本，短音频不会越界。
magnitude_db = 20 * log10(max(abs(h), eps));
plot(w, magnitude_db);
xlabel('归一化角频率 (rad/sample)');
ylabel('幅度 (dB)');
title('语音信号频谱');
grid on;

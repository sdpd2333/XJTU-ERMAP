% 读取音频文件
[x, Fs] = audioread('trip.wav');

% 2倍内插 - 零阶保持滤波器
L = 2;  % 插值因子
zero_order_interpolated = resample(x, L, 1, 0);

% 2倍内插 - 时间截断的理想低通滤波器
n = 20; % 滤波器长度
cutoff = 1 / (2 * L); % 截止频率
ideal_lp_filter = fir1(n, cutoff);
ideal_interpolated = upfirdn(x, ideal_lp_filter, L, 1);

% 5倍抽取
M = 5;  % 抽取因子
zero_order_decimated = resample(zero_order_interpolated, 1, M);
ideal_decimated = downsample(ideal_interpolated, M);

% 计算频谱
Q = 20000; % 采样点数
w = linspace(-pi, pi, Q);

Hx = fftshift(fft(x, Q));
Hzoh = fftshift(fft(zero_order_interpolated, Q));
Hideal = fftshift(fft(ideal_interpolated, Q));
Hdec = fftshift(fft(ideal_decimated, Q));

% 计算幅度响应的对数值
m1 = 20*log10(abs(Hx));
m2 = 20*log10(abs(Hzoh));
m3 = 20*log10(abs(Hideal));
m4 = 20*log10(abs(Hdec));

% 绘制频谱图
figure;
subplot(2, 2, 1);
plot(w, m1);
title('原始信号频谱');
xlabel('频率 (\omega)');
ylabel('幅度响应 (dB)');

subplot(2, 2, 2);
plot(w, m2);
title('零阶保持滤波后频谱');
xlabel('频率 (\omega)');
ylabel('幅度响应 (dB)');

subplot(2, 2, 3);
plot(w, m3);
title('理想低通滤波后频谱');
xlabel('频率 (\omega)');
ylabel('幅度响应 (dB)');

subplot(2, 2, 4);
plot(w, m4);
title('5倍抽取后频谱');
xlabel('频率 (\omega)');
ylabel('幅度响应 (dB)');

% 保存处理后的音频
filename = 'processed_audio_trip.wav';
audiowrite(filename, ideal_decimated, Fs / 2.5);

% 播放音频
sound(ideal_decimated, Fs / 2.5);

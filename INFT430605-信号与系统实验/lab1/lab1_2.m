% 用三个陷波器抑制指定频率的干扰。
[y, Fs] = audioread('7noise.wav');
y = mean(y, 2);
h1 = [1, -2*cos(0.808), 1];
h2 = [1, -2*cos(1.310), 1];
h3 = [1, -2*cos(1.709), 1];
y1 = conv(h1, y);
y2 = conv(h2, y1);
y3 = conv(h3, y2);

% 输出音频按需缩放以避免削波；频谱仍使用滤波器的原始输出。
output_audio = y3 / max(1, max(abs(y3)));
sound(output_audio, Fs);
audiowrite('processed_audio_noise.wav', output_audio, Fs);

Q = 10000;
w = linspace(-pi, pi, Q);
h = direct_spectrum(y3, w, 40000);
magnitude_db = 20 * log10(max(abs(h), eps));
plot(w, magnitude_db);
xlabel('归一化角频率 (rad/sample)');
ylabel('幅度 (dB)');
title('干扰抑制后的频谱');
grid on;

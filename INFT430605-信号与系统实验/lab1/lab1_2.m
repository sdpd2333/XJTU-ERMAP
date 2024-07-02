% 读取音频文件
[y,Fs]=audioread("7noise.wav")
% 创建滤波器
h1=[1,-2*cos(0.808),1];
h2=[1,-2*cos(1.310),1];
h3=[1,-2*cos(1.709),1];

% 应用滤波器
y1=conv(h1,y);
y2=conv(h2,y1);
y3=conv(h3,y2);
% 播放音频
sound(y3,Fs);

% 写入音频文件
filename = 'processed_audio_noise.wav';
audiowrite(filename, y3, Fs);

% 计算信噪比
Q=10000;
w=linspace(-pi,pi,Q);
n=length(y);
sum=0;
for i=1:10000
    for m=1:40000
        sum=sum+y3(m)*exp(-j*w(i)*m);
    end
    h(i)=sum;
    sum=0;
end
m0=20*log10(abs(h));
% 绘制幅度响应
plot(w,m0);
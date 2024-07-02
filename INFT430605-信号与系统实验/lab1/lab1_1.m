% 读取音频文件'7noise.wav'中的音频数据y和采样率fs
[y,fs]=audioread('7noise.wav');
% 设置采样率Q
Q=10000;
% 创建一个从-pi到pi的线性空间
w=linspace(-pi,pi,Q);
% 获取音频数据的长度
m=length(y);
% 初始化求和变量sum
sum=0;
% 遍历每个频率i
for i=1:10000
    % 遍历每个时间点n
    for n=1:40000
        % 计算每个频率i下每个时间点n的系数
        sum=sum+y(n)*exp(-j*w(i)*n);
    end
    % 存储每个频率i下的幅度值
    h(i)=sum;
    % 重置求和变量sum
    sum=0;
end
% 计算每个频率i下的幅度值，结果为20log10(幅度值)
m0=20*log10(abs(h));
% 绘制每个频率i下的幅度值
plot(w,m0);
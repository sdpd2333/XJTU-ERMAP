function [y1,y2]=rise_cos(x1,x2,fd,fs)
%x1、x2是两路输入信号，fd是信号信息位的频率，fs是信号的采样频率
%生成平方根升余弦滤波器
[yf, tf]=rcosine(fd,fs, 'fir/sqrt');
%对两路信号进行滤波
[yo1, to1]=rcosflt(x1, fd,fs,'filter/Fs',yf);
[yo2, to2]=rcosflt(x2, fd,fs,'filter/Fs',yf);
y1=yo1;
y2=yo2;
end

function [y1,y2]=rise_cos(x1,x2,fd,fs)
%x1��x2����·�����źţ�fd���ź���Ϣλ��Ƶ�ʣ�fs���źŵĲ���Ƶ��
%����ƽ�����������˲���
[yf, tf]=rcosine(fd,fs, 'fir/sqrt');
%����·�źŽ����˲�
[yo1, to1]=rcosflt(x1, fd,fs,'filter/Fs',yf);
[yo2, to2]=rcosflt(x2, fd,fs,'filter/Fs',yf);
y1=yo1;
y2=yo2;
end

function [training]=creat_training(index)

% if ~isempty(findstr(index, 'QPSK'))
%     RG=sqrt(18);
% elseif ~isempty(findstr(index, '16QAM'))
%     RG=sqrt(20);
% elseif ~isempty(findstr(index, '64QAM'))
%     RG=sqrt(20);
% else
%     error('Unimplemented modulation');
% end
    
Ns=128;
N1=320;
Nx=512;
x1=randn(1,Ns);
x2=randn(1,Ns);

x3=x1+x2.*i;%生成随机128点复数序列
y=x3(65:128);%x3的后64点用作循环前缀
y1=randn(1,N1);
y2=randn(1,N1);
y3=y1+y2.*i;%生成随机320点复数序列用作数据符号
train1=[y3 y x3 x3 y3];%帧结构，共三个符号
RG=sqrt(22);
training=train1/RG;
end
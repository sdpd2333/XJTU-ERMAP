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

x3=x1+x2.*i;%�������128�㸴������
y=x3(65:128);%x3�ĺ�64������ѭ��ǰ׺
y1=randn(1,N1);
y2=randn(1,N1);
y3=y1+y2.*i;%�������320�㸴�������������ݷ���
train1=[y3 y x3 x3 y3];%֡�ṹ������������
RG=sqrt(22);
training=train1/RG;
end
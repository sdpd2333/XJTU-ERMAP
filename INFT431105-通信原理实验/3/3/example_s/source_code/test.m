addpath 2PSK
%=====����Ϊ���ݵ��Ʋ���=====%
%-----����Դ����-----%
bit_Num = 10;
%-----ÿ����Ԫռ��20�������㣬20M��������Ϊ1M-----%
bit_Width = 10;
code_phase=[1,8];%��ͷ
[inputcode]=code_gen(code_phase);%����α��
c1 = repmat(inputcode',1,bit_Width);
descode = reshape(c1',1,length(c1).*bit_Width);
%-----�����������֡��length=500-----%
bit_trans = 2 * randi([0 1],1,bit_Num) - 1;
data_pn=dsss(bit_trans,inputcode);
%-----������չ��ÿ����Ԫ��չΪ20λ-----%
tmp1 = repmat(data_pn',1,bit_Width);
data_trans = reshape(tmp1',1,length(tmp1).*bit_Width);
%-----����I��Q��·�ز��ź�-----%
carrier_I=cos(2*pi/bit_Width*[0:bit_Width-1]);
carrier_Q=sin(2*pi/bit_Width*[0:bit_Width-1]);
%-----�ز���չ�����Ⱥ�data_trans���-----%
carrier_I=repmat(carrier_I,1,bit_Num*length(inputcode));
carrier_Q=repmat(carrier_Q,1,bit_Num*length(inputcode));
carrier=carrier_I+1i*carrier_Q;
%-----����2PSK����-----%
data_trans=data_trans.*exp(1i*pi/4);
mod_data=data_trans.*carrier;
txdata = mod_data.';
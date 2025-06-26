addpath 2PSK
%=====以下为数据调制部分=====%
%-----数据源数量-----%
bit_Num = 10;
%-----每个码元占据20个采样点，20M采样率下为1M-----%
bit_Width = 10;
code_phase=[1,8];%抽头
[inputcode]=code_gen(code_phase);%产生伪码
c1 = repmat(inputcode',1,bit_Width);
descode = reshape(c1',1,length(c1).*bit_Width);
%-----产生随机数据帧，length=500-----%
bit_trans = 2 * randi([0 1],1,bit_Num) - 1;
data_pn=dsss(bit_trans,inputcode);
%-----数据扩展，每个码元扩展为20位-----%
tmp1 = repmat(data_pn',1,bit_Width);
data_trans = reshape(tmp1',1,length(tmp1).*bit_Width);
%-----产生I、Q两路载波信号-----%
carrier_I=cos(2*pi/bit_Width*[0:bit_Width-1]);
carrier_Q=sin(2*pi/bit_Width*[0:bit_Width-1]);
%-----载波扩展，长度和data_trans相等-----%
carrier_I=repmat(carrier_I,1,bit_Num*length(inputcode));
carrier_Q=repmat(carrier_Q,1,bit_Num*length(inputcode));
carrier=carrier_I+1i*carrier_Q;
%-----键控2PSK调制-----%
data_trans=data_trans.*exp(1i*pi/4);
mod_data=data_trans.*carrier;
txdata = mod_data.';
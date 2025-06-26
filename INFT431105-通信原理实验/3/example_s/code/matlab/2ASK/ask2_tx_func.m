function txdata = ask2_tx_func(frame_len)

%=====以下为数据调制部分=====%
%-----数据源数量-----%
bit_Num = frame_len;
%-----每个码元占据20个采样点，20M采样率下为1M-----%
bit_Width = 20;
%-----产生随机数据帧，length=500-----%
bit_trans = randi([0, 1],1,bit_Num);
%-----数据扩展，每个码元扩展为20位-----%
tmp1 = repmat(bit_trans',1,bit_Width);
data_trans = reshape(tmp1',1,length(tmp1).*bit_Width);
%-----产生I、Q两路载波信号，并量化-----%
carrier_I=cos(2*pi/20*[0:19]);
carrier_Q=sin(2*pi/20*[0:19]);
%-----载波扩展，长度和data_trans相等-----%
carrier_I=repmat(carrier_I,1,bit_Num);
carrier_Q=repmat(carrier_Q,1,bit_Num);
carrier=carrier_I+1i*carrier_Q;
%-----键控2ASK信号调制-----%
mod_data=data_trans.*carrier;
txdata=mod_data.';
end


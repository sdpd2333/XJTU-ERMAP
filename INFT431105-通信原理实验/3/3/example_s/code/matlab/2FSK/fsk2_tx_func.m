function txdata = fsk2_tx_func(frame_len)

%=====以下为数据调制部分=====%
%-----数据源数量-----%
bit_Num = frame_len;
%-----产生随机数据帧，length=500-----%
bit_trans = randi([0, 1],1,bit_Num);
%-----产生两个载频，分别为1MHz和2MHz
carrier_I1=cos(2*pi/20*[0:19]);
carrier_Q1=sin(2*pi/20*[0:19]);
carrier_1M=carrier_I1+1i*carrier_Q1;
carrier_I2=cos(2*pi/10*[0:9]);
carrier_Q2=sin(2*pi/10*[0:9]);
carrier_2M=carrier_I2+1i*carrier_Q2;
%-----2MHz载波扩展为20bit，和1MHz载波等宽
carrier_2M=repmat(carrier_2M,1,2);
%-----键控调频，1-->1MHz，0-->2MHz
m1=[];
for i=1:length(bit_trans)
    if bit_trans(i)==1
        m=carrier_1M;
    else
        m=carrier_2M;
    end
    m1=[m1 m];
end
mod_data=m1;

txdata = mod_data.';

end


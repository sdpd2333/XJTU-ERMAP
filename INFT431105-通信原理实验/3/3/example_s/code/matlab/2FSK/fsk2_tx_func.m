function txdata = fsk2_tx_func(frame_len)

%=====����Ϊ���ݵ��Ʋ���=====%
%-----����Դ����-----%
bit_Num = frame_len;
%-----�����������֡��length=500-----%
bit_trans = randi([0, 1],1,bit_Num);
%-----����������Ƶ���ֱ�Ϊ1MHz��2MHz
carrier_I1=cos(2*pi/20*[0:19]);
carrier_Q1=sin(2*pi/20*[0:19]);
carrier_1M=carrier_I1+1i*carrier_Q1;
carrier_I2=cos(2*pi/10*[0:9]);
carrier_Q2=sin(2*pi/10*[0:9]);
carrier_2M=carrier_I2+1i*carrier_Q2;
%-----2MHz�ز���չΪ20bit����1MHz�ز��ȿ�
carrier_2M=repmat(carrier_2M,1,2);
%-----���ص�Ƶ��1-->1MHz��0-->2MHz
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


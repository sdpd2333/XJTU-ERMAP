function txdata = ask2_tx_func(frame_len)

%=====����Ϊ���ݵ��Ʋ���=====%
%-----����Դ����-----%
bit_Num = frame_len;
%-----ÿ����Ԫռ��20�������㣬20M��������Ϊ1M-----%
bit_Width = 20;
%-----�����������֡��length=500-----%
bit_trans = randi([0, 1],1,bit_Num);
%-----������չ��ÿ����Ԫ��չΪ20λ-----%
tmp1 = repmat(bit_trans',1,bit_Width);
data_trans = reshape(tmp1',1,length(tmp1).*bit_Width);
%-----����I��Q��·�ز��źţ�������-----%
carrier_I=cos(2*pi/20*[0:19]);
carrier_Q=sin(2*pi/20*[0:19]);
%-----�ز���չ�����Ⱥ�data_trans���-----%
carrier_I=repmat(carrier_I,1,bit_Num);
carrier_Q=repmat(carrier_Q,1,bit_Num);
carrier=carrier_I+1i*carrier_Q;
%-----����2ASK�źŵ���-----%
mod_data=data_trans.*carrier;
txdata=mod_data.';
end


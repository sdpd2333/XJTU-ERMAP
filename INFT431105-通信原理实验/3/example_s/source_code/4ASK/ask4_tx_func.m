function txdata = ask4_tx_func(frame_len)

%=====����Ϊ���ݵ��Ʋ���=====%
%-----����Դ����-----%b
bit_Num = frame_len;
%-----ÿ����Ԫռ��20�������㣬20M��������Ϊ1M-----%
bit_Width = 20;
%-----�����������֡��length=500-----%
bit_trans = randint(1,bit_Num);
%-----�����ݷֳ���ż��·
ak=bit_trans(1:2:end);
bk=bit_trans(2:2:end);
%-----����ӳ��-----%
%-----00-->0
%-----01-->1
%-----10-->2
%-----11-->3
m1=[];
for i=1:length(bit_trans)/2                  
    if((ak(i)==0))&(bk(i)==0)
        m=zeros(1,20);
    elseif((ak(i)==0))&(bk(i)==1)
        m=ones(1,20);
    elseif((ak(i)==1))&(bk(i)==0)
        m=2*ones(1,20);
    else
        m=3*ones(1,20);
    end
    m1=[m1 m];
 
end
%-----����I��Q��·�ز��źţ�������-----%
carrier_I=(cos(2*pi/20*[0:19]));
carrier_Q=(sin(2*pi/20*[0:19]));
%-----�ز���չ�����Ⱥ�data_trans/2���-----%
carrier_I=repmat(carrier_I,1,bit_Num/2);
carrier_Q=repmat(carrier_Q,1,bit_Num/2);
carrier=carrier_I+1i*carrier_Q;
%-----4ASK���ص���-----%
mod_data=m1.*carrier;

txdata = mod_data.';
end


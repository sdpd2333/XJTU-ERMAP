function [ txdata ] = scfde_tx_func()

%-----ÿ֡��Ϣ���صĴ�С-----%
FrameSize =1200*2;  
%-----������UW�Ĵ�С-----%
UW_Num = 64;  
%-----��������������-----%
uw = UW_Generate(UW_Num);     
%-----���������-----%
BitsTranstmp = randi([0 1],1,FrameSize);
%-----����ָ��-----%
index='16QAM';  
%-----���ָ��-----%
index2=index;  
%-----ӳ�����-----%
BitsTrans = modulation(BitsTranstmp, index);
%-----���UW����-----%
Adduw = zeros(1,FrameSize+2*length(uw)); 
Adduw = [uw,BitsTrans,uw];
%-----��·�źŽ���8����ֵ-----%
sig_insert1=insert_value(real(Adduw),8);
sig_insert2=insert_value(imag(Adduw),8);
%-----ͨ����ͨ�˲���-----%
[sig_rcos1,sig_rcos2]=rise_cos(sig_insert1,sig_insert2,0.25,2);
%-----��·���ݺϳ�һ·-----%
txdata_x=sig_rcos1+1i*sig_rcos2;
%-----����֡ͬ��ѵ������-----%
[training]=creat_training(index);
%-----����������֡-----%
txdata=[training txdata_x.'];
txdata=txdata.';
end


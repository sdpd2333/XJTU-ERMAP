function [ txdata ] = scfde_tx_func()

%-----每帧信息比特的大小-----%
FrameSize =1200*2;  
%-----独特字UW的大小-----%
UW_Num = 64;  
%-----产生独特字序列-----%
uw = UW_Generate(UW_Num);     
%-----产生随机数-----%
BitsTranstmp = randi([0 1],1,FrameSize);
%-----调制指数-----%
index='16QAM';  
%-----解调指数-----%
index2=index;  
%-----映射调制-----%
BitsTrans = modulation(BitsTranstmp, index);
%-----添加UW序列-----%
Adduw = zeros(1,FrameSize+2*length(uw)); 
Adduw = [uw,BitsTrans,uw];
%-----两路信号进行8倍插值-----%
sig_insert1=insert_value(real(Adduw),8);
sig_insert2=insert_value(imag(Adduw),8);
%-----通过低通滤波器-----%
[sig_rcos1,sig_rcos2]=rise_cos(sig_insert1,sig_insert2,0.25,2);
%-----两路数据合成一路-----%
txdata_x=sig_rcos1+1i*sig_rcos2;
%-----创建帧同步训练序列-----%
[training]=creat_training(index);
%-----发送数据组帧-----%
txdata=[training txdata_x.'];
txdata=txdata.';
end


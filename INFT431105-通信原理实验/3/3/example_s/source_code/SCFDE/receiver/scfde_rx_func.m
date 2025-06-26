function [ output_args ] = scfde_rx_func( rxdata )
%-----独特字UW的大小-----%
UW_Num = 64;  
%-----产生独特字序列-----%
uw = UW_Generate(UW_Num);  

a1=real(rxdata);
a2=imag(rxdata);
%-----起始帧同步-----%
[frame_data,syn_symbol] = rx_frame_sync(a1+a2,a1,a2,5872);
%-----匹配滤波-----%
[sig_match1,sig_match2] = rise_cos(real(frame_data),imag(frame_data),0.25,2);
%-----8倍降采样-----%
[x1,x2]=pick_sig(sig_match1,sig_match2,8);
%-----MMSE频域均衡-----%
rx_data=x1+1i*x2;
Signal_Rx=rx_data.';
FDE_in = Signal_Rx(1,1:(size(Signal_Rx,2)-UW_Num) );
FDE_out = MMSE_FDE( FDE_in,uw );
%-----数据归一化-----%
x1=mapminmax(real(FDE_out),-1,1);
x2=mapminmax(imag(FDE_out),-1,1);
h=figure(1);
    clf;
    set(h,'name','SC-FDE调制解调系统');
    
    subplot(221);
    plot((a1),'r');
    hold on;
    plot((a2),'g');

    
    subplot(222);
    plot(x1',x2','r.');
    axis square;
    axis([-1.2 1.2 -1.2 1.2]);
    title(['频域均衡星座图 Mod=','16QAM']);
    
    subplot(223);
    plot(syn_symbol,'black');
    ylim([0 1.2]);
%     axis square;
    subplot(224);
     pwelch(frame_data,[],[],[],20e6,'centered','psd');
     xlim([-3 3]);
     axis square;
end


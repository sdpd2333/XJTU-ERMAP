%2发1收，QPSK,8QAM,16QAM误码率曲线
load data_singleRX_QPSK.mat
ber_qpsk=ber1;
load data_singleRX_8QAM.mat
ber_8qam=ber1;
load data_singleRX_16QAM.mat
ber_16qam=ber1;
semilogy(EsN0,ber_qpsk,'-ro',EsN0,ber_8qam,'-b*',EsN0,ber_16qam,'-k+')
%axis([0 15 10^-4 1]) 
grid on
legend('QPSK','8QAM','16QAM')
xlabel('信噪比Es/N0')
ylabel('误比特率（BER）')
title('Alamouti方案在准静态瑞利衰落信道下的误码率性能,2发1收')

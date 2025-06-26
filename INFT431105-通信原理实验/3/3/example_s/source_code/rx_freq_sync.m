function [freq_offset,out_signal] = rx_freq_sync(rxdata,training_seq)

T_sym=1/10e6;
len=length(rxdata);
N=length(training_seq);

z_k=training_seq.^2;
r=zeros(1,N-1);
for k=1:N-1
    r(k)=mean(z_k(1+k:N).*conj(z_k(1:N-k)));
end

freq_offset=angle(sum(r))/(2*pi*N*T_sym);
out_signal=rxdata.*exp(-1i*2*pi*freq_offset*(1:len)*T_sym);

end
% function [out_signal, dfreq] = rx_freq_sync(rxdata,training_seq)
% 
% T_sym=1/10e6;
% 
% len_training=length(training_seq);
% 
% len_data=length(rxdata);
% 
% zr=rxdata.^2;
% 
% for m=1:len_data
%     r0(m)=mean(zr(1+m:len_data).*conj(zr(1:len_data-m)));%p70计算相关函数
% end
% dfreq=angle(sum(r0))/(2*pi*(len_data+1)*T_sym);%近似计算
% out_signal=training_seq(1:end).*exp(-1i*2*pi*dfreq*(1:len_training)*T_sym);%盲估计补偿
% 
% end


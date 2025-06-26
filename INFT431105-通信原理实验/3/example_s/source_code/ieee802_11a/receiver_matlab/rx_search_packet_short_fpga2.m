function [dc_offset,thres_idx]  = rx_search_packet_short_fpga2(rx_signal)
Ns=size(rx_signal,1);
thres_idx=Ns;
L=16;
pass=0;
for i=1:Ns-L*2
	for j=0:L-1
        rx_mean(j+1,i)=floor(mean((rx_signal(i+j:i+j+L-1))));
    end
    rx_signal_nodc1=rx_signal(i:i+L-1)-rx_mean(:,i);
    rx_signal_nodc2=rx_signal(i+L:i+L*2-1)-rx_mean(:,i);
    rx_delay_sum = sum(rx_signal_nodc1.*conj(rx_signal_nodc2));
    rx_delay_real=abs(real(rx_delay_sum));
    rx_delay_imag=abs(imag(rx_delay_sum));
    rx_delay_corr(i)=(rx_delay_real>=rx_delay_imag)*(rx_delay_real+floor(rx_delay_imag./2))+ ...
        (rx_delay_real<rx_delay_imag)*(rx_delay_imag+floor(rx_delay_real./2));
    rx_self_corr(i)  = sum(rx_signal_nodc2.*conj(rx_signal_nodc2));
    rx_corr(i)=rx_delay_corr(i)./rx_self_corr(i);
    pass_cnt(i)=pass;
    if rx_corr(i)>=0.75
        pass=pass+1;
        if pass~=31
            pass=pass+1;
        elseif pass==31
            thres_idx=i-15;break
        else
            pass=0;
        end
    else
        pass=0;
    end
end
% dc_offset=rx_mean(1,thres_idx);
figure(5);clf;
set(gcf,'name','¥÷Õ¨≤Ω');
subplot(311);plot(rx_corr);
subplot(312);plot(real(rx_mean(1,:)));hold on;plot(imag(rx_mean(1,:)));
subplot(313);plot(pass_cnt);
figure(1);
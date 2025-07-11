function [dc_offset,thres_idx]  = rx_search_packet_short_fpga3(rx_signal)
global sim_consts;
%% load local short training
short_tr = sim_consts.legacyshorttraning;
short_tr_symbols = tx_freqd_to_timed(short_tr,1,52);
Strs(:,1) = short_tr_symbols(1:16);
Strs_norm=(real(Strs)>0)*2-1+1i*((imag(Strs)>0)*2-1);
Nrx=size(rx_signal,2);
Ns=size(rx_signal,1);
Ns=size(rx_signal,1);
L=16;
thres_idx=Ns-L*2;
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
    rx_corr_stf(i)=abs(sum(rx_signal_nodc1.*conj(Strs_norm)));
    if i>16
        rx_corr_stf_mean(i)=rx_corr_stf_mean(i-1)-rx_corr_stf(i-16)/16+rx_corr_stf(i)/16;
    else
        rx_corr_stf_mean(i)=mean(rx_corr_stf(1:i));
    end
    rx_corr(i)=rx_delay_corr(i)./rx_self_corr(i);
    pass_cnt(i)=pass;
    if rx_corr(i)>=0.75
%         pass=pass+1;
        if pass~=20
            pass=pass+1;
        elseif pass==20 && i>128 && rx_corr_stf_mean(i)>rx_corr_stf_mean(i-128)*4
            thres_idx=i-15;break
        else
            pass=0;
        end
    else
        pass=0;
    end
end
% dc_offset=rx_mean(1,thres_idx);
% dc_offset=716+1i*617;;
dc_offset=0;
figure(5);clf;
set(gcf,'name','��ͬ��');
subplot(311);plot(rx_corr);
subplot(312);plot(rx_corr_stf_mean);
subplot(313);plot(pass_cnt);
figure(1);
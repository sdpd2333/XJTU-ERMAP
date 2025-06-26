function thres_idx = rx_search_packet_short(rx_signal)
Nrx=size(rx_signal,2);
Ns=size(rx_signal,1);
thres_idx=Ns;
L=16;
pass=0;
for i=1:Ns-L*2
    for j=1:Nrx
        rx_delay_corr(j) = abs(sum(rx_signal(i:i+L-1,j).*conj(rx_signal(i+L:i+L*2-1,j))));
        rx_self_corr(j)  = sum(rx_signal(i+L:i+L*2-1,j).*conj(rx_signal(i+L:i+L*2-1,j)));
        rx_power(j)=mean(abs(rx_signal(i:i+31,j)));
    end
    rx_corr(i)=mean(rx_delay_corr(j)./rx_self_corr(j));
    rx_power(i)=mean(rx_power(j));
    if rx_corr(i)>=0.75
        if pass~=15
            pass=pass+1;
        elseif pass==15 && i>128
            if rx_power(i)>=1.5*rx_power(i-127)
                thres_idx=i-15;break
            else
                pass=0;
            end
        else
            pass=0;
        end
    else
        pass=0;
    end
end
figure(2);clf;
set(gcf,'name','¥÷Õ¨≤Ω');
plot(rx_corr);
figure(1);
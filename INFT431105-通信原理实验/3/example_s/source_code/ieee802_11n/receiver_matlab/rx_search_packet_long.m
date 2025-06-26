function thres_idx=rx_search_packet_long(end_search,rx_signal)
global sim_consts;
% get time domain long training symbols
long_tr = sim_consts.legacylongtraning;
long_tr_symbols = tx_freqd_to_timed(long_tr,1,sim_consts.nonHTNumSubc);
ltrs = long_tr_symbols;
long_trs=[ltrs(end/2+1:end);ltrs(1:end/2)];
Nrx=size(rx_signal,2);
L=64;
figure(3);clf;
set(gcf,'name','¾«Í¬²½');
for i=1:Nrx
    for j=1:end_search-L*2
        rx_cross_corr(j,i) = abs(sum(rx_signal(j:j+L-1,i).*conj(long_trs)));
        rx_self_corr(j,i) = sum(rx_signal(j:j+L-1,i).*conj(rx_signal(j:j+L-1,i))).^0.5;
        rx_cross_ratio(j,i)=rx_cross_corr(j,i)./rx_self_corr(j,i);
    end
    index=find(rx_cross_ratio(:,i)>0.4);
    if length(index)>=2
        if index(2)<index(1)+48 && index(2)>=index(1)+4
            thres_idx(i)=index(2);
        else
            thres_idx(i)=index(1);
        end
        subplot(Nrx,1,i)
        plot(rx_cross_ratio(1:thres_idx+64),'r');
    else
        thres_idx(i)=end_search;
        subplot(Nrx,1,i)
        plot(rx_cross_ratio(1:thres_idx),'r');
    end
end
figure(1);
end
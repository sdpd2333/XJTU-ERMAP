function thres_idx=rx_search_packet_long(end_search,rx_signal)
global sim_consts;
% get time domain long training symbols
long_tr = sim_consts.LongTrainingSymbols;
long_tr_symbols = tx_freqd_to_timed(long_tr,1);
ltrs = long_tr_symbols.';
long_trs=[ltrs(end/2+1:end);ltrs(1:end/2)];
L=64;
for j=1:end_search-L*2
    rx_cross_corr(j) = abs(sum(rx_signal(j:j+L-1).*conj(long_trs)));
    rx_self_corr(j) = sum(rx_signal(j:j+L-1).*conj(rx_signal(j:j+L-1))).^0.5;
    rx_cross_ratio(j)=rx_cross_corr(j)./rx_self_corr(j);
end
index=find(rx_cross_ratio>0.4);
figure(3);clf;
if length(index)>=2
    if index(2)<index(1)+48 && index(2)>=index(1)+4
        thres_idx=index(2);
    else
        thres_idx=index(1);
    end
    plot(rx_cross_ratio(1:thres_idx+64),'r');
else
    thres_idx(i)=end_search;
    plot(rx_cross_ratio(1:thres_idx),'r');
end
figure(1);


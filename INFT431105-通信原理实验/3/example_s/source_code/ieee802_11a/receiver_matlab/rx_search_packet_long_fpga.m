function thres_idx=rx_search_packet_long_fpga(end_search,rx_signal)
global sim_consts;   
% get time domain long training symbols
long_tr = sim_consts.LongTrainingSymbols;
long_tr_symbols = tx_freqd_to_timed(long_tr,1);
ltrs = long_tr_symbols.';
long_trs=[ltrs(end/2+1:end);ltrs(1:end/2)];
% long_trs=[ltrs(49:64);ltrs(1:48)];
long_trs=round(long_trs.*1e4);
L=64;
no_r=1+(real(rx_signal)<0)*(-2);
no_i=1+(imag(rx_signal)<0)*(-2);
rx_norms=no_r+1i*no_i;
for j=1:end_search-L*2
    rx_cross_sum = sum(rx_norms(j:j+L-1).*conj(long_trs));
    if abs(real(rx_cross_sum))>=abs(imag(rx_cross_sum))
        rx_cross_corr(j)=abs(real(rx_cross_sum))+floor(abs(imag(rx_cross_sum))./2);
    else
        rx_cross_corr(j)=abs(imag(rx_cross_sum))+floor(abs(real(rx_cross_sum))./2);
    end
%     if rx_cross_corr(j)>5e4 
%         break
%     end
end
index=find(rx_cross_corr>4e4);
if length(index)>=2
    if index(2)<index(1)+48 && index(2)>=index(1)+4
        thres_idx=index(2);
    else
        thres_idx=index(1);
    end
    figure(3);clf;
    set(gcf,'name','精同步');
    plot(rx_cross_corr(1:thres_idx+64),'r');
    figure(1);
else
    thres_idx=end_search;
    figure(3);clf;
    set(gcf,'name','精同步');
    plot(rx_cross_corr(1:thres_idx),'r');
    figure(1);
end
end


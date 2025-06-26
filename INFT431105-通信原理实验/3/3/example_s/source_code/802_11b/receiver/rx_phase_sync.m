function [out_signal,ang] = rx_phase_sync(signal_freq_sync,local_sync)
len=length(local_sync)/11;
barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1];
signal_sync=signal_freq_sync(1:len*11);

sync_symbols=barker*reshape(local_sync,length(barker),length(local_sync)/length(barker));
despread_symbols=barker*reshape(signal_sync,length(barker),length(signal_sync)/length(barker));


L=len;
for i=1:L-1
%     cor(i)=despread_symbols(i).*sqrt((sync_symbols(L-i)).^2);
    cor(i)=sync_symbols(i).*sqrt(despread_symbols(L-i).^2);
%     cor(i)=sqrt((sync_symbols(i).^2).*(despread_symbols(L-i).^2));
end

ang=angle(mean(cor*2))+pi/2;
% ang2=angle(mean(cor2*1));
% ang=(ang1+ang2)/2;
out_signal_1=signal_freq_sync(1:2112).*exp(-1i*ang);
out_signal_2=signal_freq_sync(2113:end).*exp(-1i*ang);
out_signal=[out_signal_1 out_signal_2];
end


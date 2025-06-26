function [deltaf,out_signal] = rx_freq_fine_sync(signal_coarse_freq,local_sync)
len=length(local_sync)/11;
barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1];
rx_signal_coarse_freq=signal_coarse_freq(1:len*11);
tx_signal_sync=barker*reshape(local_sync,length(barker),length(local_sync)/length(barker));
rx_signal_sync=barker*reshape(rx_signal_coarse_freq,length(barker),length(rx_signal_coarse_freq)/length(barker));

Tchip=1/1000000;
N=len;

for m=1:N
    r(m)=rx_signal_sync(m).*conj(tx_signal_sync(m));
end

% r=r.^2;
% for m=1:32
%     d(m)=mean(r(1+m:64).*conj(r(1:64-m)));
% end
i=0;
for k=1:128/8
    i=i+1;
    d(i)=r(k).*conj(r(k+8));
end
deltaf=angle(sum(d))/(pi*(16+1)*Tchip)/2;

freq_fine_offset=deltaf/11;
out_signal=signal_coarse_freq(1:end).*exp(-1i*2*pi*freq_fine_offset*(1:length(signal_coarse_freq))*Tchip);

end
function deltaf= rx_freq_coarse_sync(rx_signal)


barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1];
signal_sync=rx_signal;
despread_symbols=barker*reshape(signal_sync,length(barker),length(signal_sync)/length(barker));
Tchip=1/1000000;
N=length(despread_symbols)/4;
L0=length(despread_symbols);

zr=despread_symbols.^2/sqrt(2);
for m=1:N
    r0(m)=mean(zr(1+m:L0).*conj(zr(1:L0-m)));
end
deltaf=angle(sum(r0))/(pi*(N+1)*Tchip)/2;
% 
% freq_offset=deltaf/11;
% 
% 
% 
% out_signal=rx_signal(1:end).*exp(-1i*2*pi*freq_offset*(1:length(rx_signal))*Tchip);


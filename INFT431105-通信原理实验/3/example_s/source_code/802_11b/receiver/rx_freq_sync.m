function [deltaf,out_signal,sig_despread] = rx_freq_sync(sync_samples,Num,samples_package)

Tchip=1/1000000;
barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1];
len=length(samples_package);
sig_despread=barker*reshape(sync_samples,11,length(sync_samples)/11);
N=length(sig_despread)/Num;
L0=length(sig_despread);

zr=sig_despread.^2;

for m=1:N
    r0(m)=mean(zr(1+m:L0).*conj(zr(1:L0-m)));
end
deltaf=angle(sum(r0))/(pi*(N+1)*Tchip)/2;
freq_offset=deltaf/11;
out_signal=samples_package(1:end).*exp(-1i*2*pi*freq_offset*(1:len)*Tchip);

end


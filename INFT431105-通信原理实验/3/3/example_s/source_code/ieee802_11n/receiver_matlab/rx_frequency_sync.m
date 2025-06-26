function [out_signal,freq_est] = rx_frequency_sync(rx_signal)
Nrx=size(rx_signal,2);
Ns=size(rx_signal,1);
D=64; 
for i=1:Nrx
    phase=rx_signal(1:64,i).*conj(rx_signal(65:128,i));   
    phase=sum(phase);   
    freq_est(i)=-angle(phase)/(2*D*pi/20000000);
    radians_per_sample = -angle(phase)/D;
    time_base=0:Ns-1;
    correction_signal=exp(-1i*radians_per_sample*time_base);
    out_signal(:,i) = rx_signal(:,i).*correction_signal.';
end

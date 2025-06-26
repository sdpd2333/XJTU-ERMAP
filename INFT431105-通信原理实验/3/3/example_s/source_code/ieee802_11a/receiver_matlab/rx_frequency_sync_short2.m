function [out_signal, freq_est] = rx_frequency_sync_short2(rxsignal)
    % short training symbol periodicity
    D = 16;
    plateu264(1)=0;
    for i=1:160
        plateu2(i) = sum(rxsignal(i:i+15).*conj(rxsignal(i+16:i+31)));
        plateu264(i+1)=plateu264(i)*(1-1/16)+plateu2(i)/16;
    end
    [plateu,I]=max(abs(plateu264));
    Fs=-angle(plateu264(I));
    Fsc=Fs/D;
    freq_est=Fsc/(2*pi)*20e6;
    % Now create a signal that has the frequency offset in the other direction
    time_base=[0:length(rxsignal)-1].';
    correction_signal=exp(-1i*Fsc*time_base);
    out_signal = rxsignal.*correction_signal;
end
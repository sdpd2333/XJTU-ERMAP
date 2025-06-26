function [out_signal, freq_est] = rx_frequency_sync_short(rxsignal)
    % short training symbol periodicity
    D = 16;
    for i=1:4
        phase(i) = sum(rxsignal((i-1)*16+1:i*16).*conj(rxsignal(i*16+1:(i+1)*16)));
    end
    % with rx diversity combine antennas
    freq_est = -mean(angle(phase) / (2*D*pi/20000000));
freq_est
    radians_per_sample = 2*pi*freq_est/20000000;
    % Now create a signal that has the frequency offset in the other direction
    time_base=[0:length(rxsignal)-1].';
    correction_signal=exp(-1i*radians_per_sample*time_base);
    out_signal = rxsignal.*correction_signal;
end
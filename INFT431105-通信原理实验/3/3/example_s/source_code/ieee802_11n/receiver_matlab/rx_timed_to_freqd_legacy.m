function [freq_legacy_ltf,freq_legacy_sig,freq_highthrough_sig] = rx_timed_to_freqd_legacy(time_signal)
global sim_consts;
Nrx=size(time_signal,2);
reorder = [33:64 1:32];
for i=1:Nrx
    % non-HT long training
    lltf=time_signal(1:128,i);
    lltf_sym=reshape(lltf,64,2);
    legacy_ltf=fft(lltf_sym);
    legacy_ltf(reorder,:)=legacy_ltf;
    legacy_ltf_use=legacy_ltf(sim_consts.nonHTUsedSubcIdx,:);
    freq_legacy_ltf(:,i)=legacy_ltf_use(:);
    % non-HT signal
    lsig=time_signal(129:128+80,i);
    lsig(1:16)=[];
    freq_lsig=fft(lsig);
    freq_lsig(reorder,:)=freq_lsig;
    freq_legacy_sig(:,i)=freq_lsig(sim_consts.nonHTUsedSubcIdx,:);
    % HT signal
    hsig=time_signal(209:208+160,i);
    hsig_sym=reshape(hsig,80,2);
    hsig_sym(1:16,:)=[];
    freq_hsig=fft(hsig_sym);
    freq_hsig(reorder,:)=freq_hsig;
    freq_hsig_use=freq_hsig(sim_consts.nonHTUsedSubcIdx,:);
    freq_highthrough_sig(:,i)=freq_hsig_use(:);
end


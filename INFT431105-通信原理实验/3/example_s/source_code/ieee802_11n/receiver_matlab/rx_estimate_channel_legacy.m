function channel_estimate = rx_estimate_channel_legacy(freq_legacy_ltf)
global sim_consts;
Nrx=size(freq_legacy_ltf,2);
for i=1:Nrx
    freq_legacy_ltf_sym=reshape(freq_legacy_ltf(:,i),52,2);
    mean_symbols=mean(freq_legacy_ltf_sym.');
    channel_estimate(:,i)=mean_symbols.*conj(sim_consts.legacylongtraning);
end

function time_syms = tx_freqd_to_timed(mod_ofdm_syms,up,NumSubc) 
global sim_consts;
num_symbols=length(mod_ofdm_syms)/NumSubc;
mod_grp = reshape(mod_ofdm_syms,NumSubc,num_symbols);
syms_into_ifft = zeros(64*up,num_symbols);
syms_into_ifft(2:2+NumSubc/2-1,:)=mod_grp(NumSubc/2+1:end,:);
syms_into_ifft(end-NumSubc/2+1:end,:)=mod_grp(1:NumSubc/2,:);
% Convert to time domain
ifft_out = ifft(syms_into_ifft);
time_syms = ifft_out;
end

function time_syms = tx_freqd_to_timed(mod_ofdm_syms,up) 

global sim_consts;
num_symbols = size(mod_ofdm_syms, 2)/sim_consts.NumSubc;

resample_patt=[33:64 1:32];
time_syms = zeros(1,num_symbols*64*up);
% Convert signal to time domain
syms_into_ifft = zeros(64, num_symbols);
syms_into_ifft(sim_consts.UsedSubcIdx,:) = reshape(mod_ofdm_syms, ...
    sim_consts.NumSubc, num_symbols);
syms_into_ifft(resample_patt,:) = syms_into_ifft;
syms_into_ifft_up=zeros(64*up,num_symbols);
syms_into_ifft_up(1:32,:)=syms_into_ifft(1:32,:);
syms_into_ifft_up(end-31:end,:)=syms_into_ifft(33:64,:);
% Convert to time domain
ifft_out = ifft(syms_into_ifft_up);
time_syms = ifft_out(:).';

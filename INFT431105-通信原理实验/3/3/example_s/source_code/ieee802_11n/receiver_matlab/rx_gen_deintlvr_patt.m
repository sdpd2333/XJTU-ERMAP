function idx = rx_gen_deintlvr_patt(interleaver_depth,NumDataSubc)
n_syms_per_ofdm_sym = NumDataSubc;
idx=zeros(1, interleaver_depth);
s = max([interleaver_depth/n_syms_per_ofdm_sym/2 1]);
perm_patt = s*floor((0:interleaver_depth-1)/s)+ ...
   mod((0:interleaver_depth-1)+floor(16*(0:interleaver_depth-1)/interleaver_depth),s);
deintlvr_patt = 16*perm_patt - (interleaver_depth-1)*floor(16*perm_patt/interleaver_depth);
idx = deintlvr_patt + 1;


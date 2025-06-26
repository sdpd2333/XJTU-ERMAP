
function idx = tx_gen_intlvr_patt(interleaver_depth)

global sim_consts;

n_syms_per_ofdm_sym = sim_consts.NumDataSubc;
idx=zeros(1,interleaver_depth);

s = max([interleaver_depth/n_syms_per_ofdm_sym/2 1]);

intlvr_patt = interleaver_depth/16*rem(0:interleaver_depth-1,16) + floor((0:interleaver_depth-1)/16);

perm_patt = s*floor(intlvr_patt/s)+ ...
   mod(intlvr_patt+interleaver_depth-floor(16*intlvr_patt/interleaver_depth),s);

idx = perm_patt+1;


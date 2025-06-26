
function idx = rx_gen_deintlvr_patt(interleaver_depth)

global sim_consts;

idx = zeros(1, interleaver_depth);
s = max([interleaver_depth/sim_consts.NumDataSubc/2 1]);

perm_patt = s*floor((0:interleaver_depth-1)/s)+ ...
   mod((0:interleaver_depth-1)+floor(16*(0:interleaver_depth-1)/interleaver_depth),s);

deintlvr_patt = 16*perm_patt - (interleaver_depth-1)*floor(16*perm_patt/interleaver_depth);

idx = deintlvr_patt + 1;


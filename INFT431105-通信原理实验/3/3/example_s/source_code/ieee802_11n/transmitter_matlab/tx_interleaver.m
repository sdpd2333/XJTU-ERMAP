function interleaved_bits = tx_interleaver(in_bits, NumDataSubc, Nbpscs)
interleaver_depth = NumDataSubc * Nbpscs;
num_symbols = length(in_bits)/interleaver_depth;
% Get interleaver pattern for symbols
single_intlvr_patt = tx_gen_intlvr_patt(interleaver_depth, NumDataSubc);
% Generate intereleaver pattern for the whole packet
intlvr_patt = interleaver_depth*ones(interleaver_depth, num_symbols);
intlvr_patt = intlvr_patt*diag(0:num_symbols-1);
intlvr_patt = intlvr_patt+repmat(single_intlvr_patt', 1, num_symbols);
intlvr_patt = intlvr_patt(:);
% Perform interleaving
interleaved_bits(intlvr_patt) = in_bits;

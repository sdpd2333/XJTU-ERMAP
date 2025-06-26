function out_bits=rx_deinterleave(in_bits, NumDataSubc, Nbpscs)
interleaver_depth = NumDataSubc*Nbpscs; 
num_symbols = length(in_bits)/interleaver_depth;
% Get deinterleaver pattern for symbols
single_deintlvr_patt = rx_gen_deintlvr_patt(interleaver_depth,NumDataSubc);
% Generate deintereleaver pattern for the whole packet
deintlvr_patt = interleaver_depth*ones(interleaver_depth, num_symbols);
deintlvr_patt = deintlvr_patt*diag(0:num_symbols-1);
deintlvr_patt = deintlvr_patt+repmat(single_deintlvr_patt', 1, num_symbols);
deintlvr_patt = deintlvr_patt(:);
% Perform interleaving
out_bits(deintlvr_patt) = in_bits;


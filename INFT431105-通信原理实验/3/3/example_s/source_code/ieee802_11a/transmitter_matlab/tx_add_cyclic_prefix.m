function time_signal = tx_add_cyclic_prefix(time_syms,up)
num_symbols = size(time_syms, 2)/(64*up);
time_signal = zeros(1,num_symbols*80*up);
% Add cyclic prefix
symbols = reshape(time_syms, 64*up, num_symbols);
tmp_syms = [symbols(end-16*up+1:end,:) ; symbols]; 
time_signal = tmp_syms(:).';



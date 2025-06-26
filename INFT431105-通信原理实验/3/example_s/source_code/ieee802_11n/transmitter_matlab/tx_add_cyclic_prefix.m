function time_signal = tx_add_cyclic_prefix(time_syms,up)
time_signal = [time_syms(end-16*up+1:end,:) ; time_syms]; 
time_signal=time_signal(:);
end



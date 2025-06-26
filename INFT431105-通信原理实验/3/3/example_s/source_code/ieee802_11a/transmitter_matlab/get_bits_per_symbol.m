function num_bits = get_bits_per_symbol(mod_order)

if ~isempty(strmatch(mod_order, 'BPSK ','exact'))
	num_bits=1;
elseif ~isempty(strmatch(mod_order, 'QPSK ','exact'))
   num_bits=2;
elseif ~isempty(strmatch(mod_order, '16QAM','exact'))
   num_bits=4;
elseif ~isempty(strmatch(mod_order, '64QAM','exact'))
   num_bits=6;
else
   error('Undefined modulation');
end


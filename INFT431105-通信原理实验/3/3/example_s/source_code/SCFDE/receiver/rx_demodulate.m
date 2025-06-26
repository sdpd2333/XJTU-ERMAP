

function [soft_bits_out,evm]  = rx_demodulate(rx_symbols, Modulation)
    evm=0;
if ~isempty(findstr(Modulation, 'BPSK'))
	[soft_bits,evm] = rx_bpsk_demod(rx_symbols);
elseif ~isempty(findstr(Modulation, 'QPSK'))
   [soft_bits,evm] = rx_qpsk_demod(rx_symbols);
elseif ~isempty(findstr(Modulation, '16QAM'))	
   [soft_bits,evm] = rx_qam16_demod(rx_symbols);
elseif ~isempty(findstr(Modulation, '64QAM'))
   [soft_bits,evm] = rx_qam64_demod(rx_symbols);
else
   error('Undefined modulation');
end

soft_bits_out = soft_bits(:)';


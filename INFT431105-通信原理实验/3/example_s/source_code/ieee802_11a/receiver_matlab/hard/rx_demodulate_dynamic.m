

function [soft_bits_out,evm]  = rx_demodulate_dynamic(rx_symbols,chan_amp,Modulation)
    evm=0;
if ~isempty(findstr(Modulation, 'BPSK'))
	[soft_bits,evm] = rx_bpsk_demod_dynamic(rx_symbols,chan_amp);
elseif ~isempty(findstr(Modulation, 'QPSK'))
   [soft_bits,evm] = rx_qpsk_demod_dynamic(rx_symbols,chan_amp);
elseif ~isempty(findstr(Modulation, '16QAM'))	
   [soft_bits,evm] = rx_qam16_demod_dynamic(rx_symbols,chan_amp);
elseif ~isempty(findstr(Modulation, '64QAM'))
   [soft_bits,evm] = rx_qam64_demod_dynamic(rx_symbols,chan_amp);
else
   error('Undefined modulation');
end

soft_bits_out = soft_bits(:)';


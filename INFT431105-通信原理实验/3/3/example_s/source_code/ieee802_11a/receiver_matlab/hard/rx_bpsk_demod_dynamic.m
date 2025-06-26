

function [soft_bits,evm] = rx_bpsk_demod_dynamic(rx_symbols,chan_amp)

soft_bits = double(real(rx_symbols)>0); 

evm_real=abs(real(rx_symbols))./chan_amp-1;
evm_image=imag(rx_symbols)./chan_amp;
evm=(evm_real.^2+evm_image.^2).^0.5;
evm=sum(evm)/length(evm);



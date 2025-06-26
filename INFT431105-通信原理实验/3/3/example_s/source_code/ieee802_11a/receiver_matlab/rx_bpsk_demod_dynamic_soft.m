function [soft_bits,evm] = rx_bpsk_demod_dynamic_soft(rx_symbols,chan_amp)
soft_tmp=real(rx_symbols);
th_1p4=chan_amp.*0.25;
th_2p4=chan_amp.*0.5;
th_3p4=chan_amp.*0.75;
for i=1:length(soft_tmp)
    if soft_tmp(i)<-th_3p4(i)
        soft_bits(i)=0;
    elseif -th_3p4(i)<=soft_tmp(i) && soft_tmp(i)<-th_2p4(i)
        soft_bits(i)=1;
    elseif -th_2p4(i)<=soft_tmp(i) && soft_tmp(i)<-th_1p4(i)
        soft_bits(i)=2;
    elseif -th_1p4(i)<=soft_tmp(i) && soft_tmp(i)<0
        soft_bits(i)=3;
    elseif 0<=soft_tmp(i) && soft_tmp(i)<th_1p4(i)
        soft_bits(i)=4;
    elseif th_1p4(i)<=soft_tmp(i) && soft_tmp(i)<th_2p4(i)
        soft_bits(i)=5;
    elseif th_2p4(i)<=soft_tmp(i) && soft_tmp(i)<th_3p4(i)
        soft_bits(i)=6;
    elseif th_3p4(i)<=soft_tmp(i)
        soft_bits(i)=7;
    end
end
evm_real=abs(real(rx_symbols))./chan_amp-1;
evm_image=imag(rx_symbols)./chan_amp;
evm=(evm_real.^2+evm_image.^2).^0.5;
evm=sum(evm)/length(evm);
% 
function [soft_bits,evm] = rx_qam16_demod_dynamic(rx_symbols,chan_amp)

soft_bits = zeros(4,length(rx_symbols));  % Each symbol consists of 4 bits

bit0 = double(real(rx_symbols)>0);
bit2 = double(imag(rx_symbols)>0);
bit1 = double((2/sqrt(10).*chan_amp-abs(real(rx_symbols)))>0);
bit3 = double((2/sqrt(10).*chan_amp-abs(imag(rx_symbols)))>0);

soft_bits(1,:) = bit0;
soft_bits(2,:) = bit1;
soft_bits(3,:) = bit2;
soft_bits(4,:) = bit3;

evm_real=zeros(1,length(rx_symbols));
evm_image=zeros(1,length(rx_symbols));
rx_symbols_nom=rx_symbols./chan_amp;
for i=1:length(rx_symbols)
    soft_bits_i=soft_bits(:,i);
    if(soft_bits_i==[0;0;1;0])
        evm_real(i)=real(rx_symbols_nom(i))+3/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))-3/sqrt(10);
    elseif(soft_bits_i==[0;1;1;0])
        evm_real(i)=real(rx_symbols_nom(i))+1/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))-3/sqrt(10);
    elseif(soft_bits_i==[1;1;1;0])
        evm_real(i)=real(rx_symbols_nom(i))-1/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))-3/sqrt(10);
    elseif(soft_bits_i==[1;0;1;0])
        evm_real(i)=real(rx_symbols_nom(i))-3/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))-3/sqrt(10);    
    elseif(soft_bits_i==[0;0;1;1])
        evm_real(i)=real(rx_symbols_nom(i))+3/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))-1/sqrt(10);   
    elseif(soft_bits_i==[0;1;1;1])
        evm_real(i)=real(rx_symbols_nom(i))+1/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))-1/sqrt(10);  
    elseif(soft_bits_i==[1;1;1;1])
        evm_real(i)=real(rx_symbols_nom(i))-1/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))-1/sqrt(10);    
    elseif(soft_bits_i==[1;0;1;1])
        evm_real(i)=real(rx_symbols_nom(i))-3/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))-1/sqrt(10);
    elseif(soft_bits_i==[0;0;0;1])
        evm_real(i)=real(rx_symbols_nom(i))+3/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))+1/sqrt(10);        
    elseif(soft_bits_i==[0;1;0;1])
        evm_real(i)=real(rx_symbols_nom(i))+1/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))+1/sqrt(10);            
    elseif(soft_bits_i==[1;1;0;1])
        evm_real(i)=real(rx_symbols_nom(i))-1/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))+1/sqrt(10);
    elseif(soft_bits_i==[1;0;0;1])
        evm_real(i)=real(rx_symbols_nom(i))-3/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))+1/sqrt(10); 
    elseif(soft_bits_i==[0;0;0;0])
        evm_real(i)=real(rx_symbols_nom(i))+3/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))+3/sqrt(10); 
    elseif(soft_bits_i==[0;1;0;0])
        evm_real(i)=real(rx_symbols_nom(i))+1/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))+3/sqrt(10);  
    elseif(soft_bits_i==[1;1;0;0])
        evm_real(i)=real(rx_symbols_nom(i))-1/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))+3/sqrt(10);    
    else
        evm_real(i)=real(rx_symbols_nom(i))-3/sqrt(10);
        evm_image(i)=imag(rx_symbols_nom(i))+3/sqrt(10);
    end
end
   
evm=(evm_real.^2+evm_image.^2).^0.5;
evm=sum(evm)/length(evm);

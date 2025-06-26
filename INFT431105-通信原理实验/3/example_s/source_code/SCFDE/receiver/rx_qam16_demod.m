% 
function [soft_bits,evm] = rx_qam16_demod(rx_symbols)

soft_bits = zeros(4,length(rx_symbols));  % Each symbol consists of 4 bits

bit0 = real(rx_symbols);
for i=1:length(rx_symbols)
    if(bit0(i)>0)
        bit0(i)=1;
    else 
        bit0(i)=0;
    end
end

bit2 = imag(rx_symbols);
for j=1:length(rx_symbols)
    if(bit2(j)>0)
        bit2(j)=1;
    else
        bit2(j)=0;
    end
end

bit1 = 2/sqrt(10)-(abs(real(rx_symbols)));
for i=1:length(rx_symbols)
    if(bit1(i)>0)
        bit1(i)=1;
    else
        bit1(i)=0;
    end
end

bit3 = 2/sqrt(10)-(abs(imag(rx_symbols)));
for j=1:length(rx_symbols)
    if(bit3(j)>0)
        bit3(j)=1;
    else
        bit3(j)=0;
    end
end

soft_bits(1,:) = bit0;
soft_bits(2,:) = bit1;
soft_bits(3,:) = bit2;
soft_bits(4,:) = bit3;

evm_real=zeros(1,length(rx_symbols));
evm_image=zeros(1,length(rx_symbols));

for i=1:length(rx_symbols)
    soft_bits_i=soft_bits(:,i);
    if(soft_bits_i==[0;0;1;0])
        evm_real(i)=real(rx_symbols(i))+3/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))-3/sqrt(10);
    elseif(soft_bits_i==[0;1;1;0])
        evm_real(i)=real(rx_symbols(i))+1/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))-3/sqrt(10);
    elseif(soft_bits_i==[1;1;1;0])
        evm_real(i)=real(rx_symbols(i))-1/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))-3/sqrt(10);
    elseif(soft_bits_i==[1;0;1;0])
        evm_real(i)=real(rx_symbols(i))-3/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))-3/sqrt(10);    
    elseif(soft_bits_i==[0;0;1;1])
        evm_real(i)=real(rx_symbols(i))+3/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))-1/sqrt(10);   
    elseif(soft_bits_i==[0;1;1;1])
        evm_real(i)=real(rx_symbols(i))+1/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))-1/sqrt(10);  
    elseif(soft_bits_i==[1;1;1;1])
        evm_real(i)=real(rx_symbols(i))-1/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))-1/sqrt(10);    
    elseif(soft_bits_i==[1;0;1;1])
        evm_real(i)=real(rx_symbols(i))-3/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))-1/sqrt(10);
    elseif(soft_bits_i==[0;0;0;1])
        evm_real(i)=real(rx_symbols(i))+3/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))+1/sqrt(10);        
    elseif(soft_bits_i==[0;1;0;1])
        evm_real(i)=real(rx_symbols(i))+1/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))+1/sqrt(10);            
    elseif(soft_bits_i==[1;1;0;1])
        evm_real(i)=real(rx_symbols(i))-1/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))+1/sqrt(10);
    elseif(soft_bits_i==[1;0;0;1])
        evm_real(i)=real(rx_symbols(i))-3/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))+1/sqrt(10); 
    elseif(soft_bits_i==[0;0;0;0])
        evm_real(i)=real(rx_symbols(i))+3/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))+3/sqrt(10); 
    elseif(soft_bits_i==[0;1;0;0])
        evm_real(i)=real(rx_symbols(i))+1/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))+3/sqrt(10);  
    elseif(soft_bits_i==[1;1;0;0])
        evm_real(i)=real(rx_symbols(i))-1/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))+3/sqrt(10);    
    else
        evm_real(i)=real(rx_symbols(i))-3/sqrt(10);
        evm_image(i)=imag(rx_symbols(i))+3/sqrt(10);
    end
end
   
evm=(evm_real.^2+evm_image.^2).^0.5;
evm=sum(evm)/length(evm);



function [soft_bits,evm] = rx_qam64_demod(rx_symbols)

soft_bits = zeros(6,length(rx_symbols));  % Each symbol consists of 6 bits
bit2=zeros(1,length(rx_symbols));
bit5=zeros(1,length(rx_symbols));

bit0 = real(rx_symbols);
for i=1:length(rx_symbols)
    if(bit0(i)>0)
        bit0(i)=1;
    else
        bit0(i)=0;
    end
end

bit3 = imag(rx_symbols);
for i=1:length(rx_symbols)
    if(bit3(i)>0)
        bit3(i)=1;
    else
        bit3(i)=0;
    end
end

bit1 = 4/sqrt(42)-abs(real(rx_symbols));
for i=1:length(rx_symbols)
    if(bit1(i)>0)
        bit1(i)=1;
    else
        bit1(i)=0;
    end
end

bit4 = 4/sqrt(42)-abs(imag(rx_symbols));
for i=1:length(rx_symbols)
    if(bit4(i)>0)
        bit4(i)=1;
    else
        bit4(i)=0;
    end
end

for m=1:length(rx_symbols)
     if abs(4/sqrt(42)-abs(real(rx_symbols(m))))<=2/sqrt(42) % bit is one
         bit2(m) = 1;
     else
         bit2(m) = 0; % bit is zero 
     end;
      
     if abs(4/sqrt(42)-abs(imag(rx_symbols(m)))) <= 2/sqrt(42)  % bit is one
         bit5(m) = 1;
     else
         bit5(m) = 0;
     end;
end;

soft_bits(1,:) = bit0;
soft_bits(2,:) = bit1;
soft_bits(3,:) = bit2;
soft_bits(4,:) = bit3;
soft_bits(5,:) = bit4;
soft_bits(6,:) = bit5;

evm_real=zeros(1,length(rx_symbols));
evm_image=zeros(1,length(rx_symbols));

for i=1:length(rx_symbols)
    soft_bits_i=soft_bits(:,i);
    if(soft_bits_i==[0;0;0;1;0;0])
        evm_real(i)=real(rx_symbols(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-7/sqrt(42);
    elseif(soft_bits_i==[0;0;1;1;0;0])
        evm_real(i)=real(rx_symbols(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-7/sqrt(42);
    elseif(soft_bits_i==[0;1;1;1;0;0])
        evm_real(i)=real(rx_symbols(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-7/sqrt(42);    
    elseif(soft_bits_i==[0;1;0;1;0;0])
        evm_real(i)=real(rx_symbols(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-7/sqrt(42);    
    elseif(soft_bits_i==[1;1;0;1;0;0])
        evm_real(i)=real(rx_symbols(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-7/sqrt(42); 
    elseif(soft_bits_i==[1;1;1;1;0;0])
        evm_real(i)=real(rx_symbols(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-7/sqrt(42); 
    elseif(soft_bits_i==[1;0;1;1;0;0])
        evm_real(i)=real(rx_symbols(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-7/sqrt(42);    
    elseif(soft_bits_i==[1;0;0;1;0;0])
        evm_real(i)=real(rx_symbols(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-7/sqrt(42); 
        
        
    elseif(soft_bits_i==[0;0;0;1;0;1])
        evm_real(i)=real(rx_symbols(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-5/sqrt(42);
    elseif(soft_bits_i==[0;0;1;1;0;1])
        evm_real(i)=real(rx_symbols(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-5/sqrt(42);
    elseif(soft_bits_i==[0;1;1;1;0;1])
        evm_real(i)=real(rx_symbols(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-5/sqrt(42);    
    elseif(soft_bits_i==[0;1;0;1;0;1])
        evm_real(i)=real(rx_symbols(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-5/sqrt(42);    
    elseif(soft_bits_i==[1;1;0;1;0;1])
        evm_real(i)=real(rx_symbols(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-5/sqrt(42); 
    elseif(soft_bits_i==[1;1;1;1;0;1])
        evm_real(i)=real(rx_symbols(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-5/sqrt(42); 
    elseif(soft_bits_i==[1;0;1;1;0;1])
        evm_real(i)=real(rx_symbols(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-5/sqrt(42);    
    elseif(soft_bits_i==[1;0;0;1;0;1])
        evm_real(i)=real(rx_symbols(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-5/sqrt(42); 

    elseif(soft_bits_i==[0;0;0;1;1;1])
        evm_real(i)=real(rx_symbols(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-3/sqrt(42);
    elseif(soft_bits_i==[0;0;1;1;1;1])
        evm_real(i)=real(rx_symbols(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-3/sqrt(42);
    elseif(soft_bits_i==[0;1;1;1;1;1])
        evm_real(i)=real(rx_symbols(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-3/sqrt(42);    
    elseif(soft_bits_i==[0;1;0;1;1;1])
        evm_real(i)=real(rx_symbols(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-3/sqrt(42);    
    elseif(soft_bits_i==[1;1;0;1;1;1])
        evm_real(i)=real(rx_symbols(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-3/sqrt(42); 
    elseif(soft_bits_i==[1;1;1;1;1;1])
        evm_real(i)=real(rx_symbols(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-3/sqrt(42); 
    elseif(soft_bits_i==[1;0;1;1;1;1])
        evm_real(i)=real(rx_symbols(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-3/sqrt(42);    
    elseif(soft_bits_i==[1;0;0;1;1;1])
        evm_real(i)=real(rx_symbols(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-3/sqrt(42); 

    elseif(soft_bits_i==[0;0;0;1;1;0])
        evm_real(i)=real(rx_symbols(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-1/sqrt(42);
    elseif(soft_bits_i==[0;0;1;1;1;0])
        evm_real(i)=real(rx_symbols(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-1/sqrt(42);
    elseif(soft_bits_i==[0;1;1;1;1;0])
        evm_real(i)=real(rx_symbols(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-1/sqrt(42);    
    elseif(soft_bits_i==[0;1;0;1;1;0])
        evm_real(i)=real(rx_symbols(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-1/sqrt(42);    
    elseif(soft_bits_i==[1;1;0;1;1;0])
        evm_real(i)=real(rx_symbols(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-1/sqrt(42); 
    elseif(soft_bits_i==[1;1;1;1;1;0])
        evm_real(i)=real(rx_symbols(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-1/sqrt(42); 
    elseif(soft_bits_i==[1;0;1;1;1;0])
        evm_real(i)=real(rx_symbols(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-1/sqrt(42);    
    elseif(soft_bits_i==[1;0;0;1;1;0])
        evm_real(i)=real(rx_symbols(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))-1/sqrt(42); 
        
    elseif(soft_bits_i==[0;0;0;0;1;0])
        evm_real(i)=real(rx_symbols(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+1/sqrt(42);
    elseif(soft_bits_i==[0;0;1;0;1;0])
        evm_real(i)=real(rx_symbols(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+1/sqrt(42);
    elseif(soft_bits_i==[0;1;1;0;1;0])
        evm_real(i)=real(rx_symbols(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+1/sqrt(42);    
    elseif(soft_bits_i==[0;1;0;0;1;0])
        evm_real(i)=real(rx_symbols(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+1/sqrt(42);    
    elseif(soft_bits_i==[1;1;0;0;1;0])
        evm_real(i)=real(rx_symbols(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+1/sqrt(42); 
    elseif(soft_bits_i==[1;1;1;0;1;0])
        evm_real(i)=real(rx_symbols(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+1/sqrt(42); 
    elseif(soft_bits_i==[1;0;1;0;1;0])
        evm_real(i)=real(rx_symbols(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+1/sqrt(42);    
    elseif(soft_bits_i==[1;0;0;0;1;0])
        evm_real(i)=real(rx_symbols(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+1/sqrt(42);     
        
    elseif(soft_bits_i==[0;0;0;0;1;1])
        evm_real(i)=real(rx_symbols(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+3/sqrt(42);
    elseif(soft_bits_i==[0;0;1;0;1;1])
        evm_real(i)=real(rx_symbols(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+3/sqrt(42);
    elseif(soft_bits_i==[0;1;1;0;1;1])
        evm_real(i)=real(rx_symbols(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+3/sqrt(42);    
    elseif(soft_bits_i==[0;1;0;0;1;1])
        evm_real(i)=real(rx_symbols(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+3/sqrt(42);    
    elseif(soft_bits_i==[1;1;0;0;1;1])
        evm_real(i)=real(rx_symbols(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+3/sqrt(42); 
    elseif(soft_bits_i==[1;1;1;0;1;1])
        evm_real(i)=real(rx_symbols(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+3/sqrt(42); 
    elseif(soft_bits_i==[1;0;1;0;1;1])
        evm_real(i)=real(rx_symbols(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+3/sqrt(42);    
    elseif(soft_bits_i==[1;0;0;0;1;1])
        evm_real(i)=real(rx_symbols(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+3/sqrt(42);     

    elseif(soft_bits_i==[0;0;0;0;0;1])
        evm_real(i)=real(rx_symbols(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+5/sqrt(42);
    elseif(soft_bits_i==[0;0;1;0;0;1])
        evm_real(i)=real(rx_symbols(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+5/sqrt(42);
    elseif(soft_bits_i==[0;1;1;0;0;1])
        evm_real(i)=real(rx_symbols(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+5/sqrt(42);    
    elseif(soft_bits_i==[0;1;0;0;0;1])
        evm_real(i)=real(rx_symbols(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+5/sqrt(42);    
    elseif(soft_bits_i==[1;1;0;0;0;1])
        evm_real(i)=real(rx_symbols(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+5/sqrt(42); 
    elseif(soft_bits_i==[1;1;1;0;0;1])
        evm_real(i)=real(rx_symbols(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+5/sqrt(42); 
    elseif(soft_bits_i==[1;0;1;0;0;1])
        evm_real(i)=real(rx_symbols(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+5/sqrt(42);    
    elseif(soft_bits_i==[1;0;0;0;0;1])
        evm_real(i)=real(rx_symbols(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+5/sqrt(42);     
        
    elseif(soft_bits_i==[0;0;0;0;0;0])
        evm_real(i)=real(rx_symbols(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+7/sqrt(42);
    elseif(soft_bits_i==[0;0;1;0;0;0])
        evm_real(i)=real(rx_symbols(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+7/sqrt(42);
    elseif(soft_bits_i==[0;1;1;0;0;0])
        evm_real(i)=real(rx_symbols(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+7/sqrt(42);    
    elseif(soft_bits_i==[0;1;0;0;0;0])
        evm_real(i)=real(rx_symbols(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+7/sqrt(42);    
    elseif(soft_bits_i==[1;1;0;0;0;0])
        evm_real(i)=real(rx_symbols(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+7/sqrt(42); 
    elseif(soft_bits_i==[1;1;1;0;0;0])
        evm_real(i)=real(rx_symbols(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+7/sqrt(42); 
    elseif(soft_bits_i==[1;0;1;0;0;0])
        evm_real(i)=real(rx_symbols(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+7/sqrt(42);    
    else
        evm_real(i)=real(rx_symbols(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols(i))+7/sqrt(42);         
    end
    
end
    
evm=(evm_real.^2+evm_image.^2).^0.5;
evm=sum(evm)/length(evm);


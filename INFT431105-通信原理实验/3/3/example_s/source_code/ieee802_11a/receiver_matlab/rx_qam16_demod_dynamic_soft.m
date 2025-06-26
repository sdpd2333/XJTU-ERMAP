function [soft_bits,evm] = rx_qam16_demod_dynamic_soft(rx_symbols,chan_amp)
soft_bits = zeros(4,length(rx_symbols));  % Each symbol consists of 4 bits
soft_tmp(1,:)=real(rx_symbols);
soft_tmp(2,:)=imag(rx_symbols);
th_1p4=chan_amp/10^0.5*0.25;
th_2p4=chan_amp/10^0.5*0.5;
th_3p4=chan_amp/10^0.5*0.75;
for i=1:size(soft_tmp,1)
    for j=1:size(soft_tmp,2)
        if soft_tmp(i,j)<-th_3p4(j)
            soft_bits02(i,j)=0;
        elseif -th_3p4(j)<=soft_tmp(i,j) && soft_tmp(i,j)<-th_2p4(j)
            soft_bits02(i,j)=1;
        elseif -th_2p4(j)<=soft_tmp(i,j) && soft_tmp(i,j)<-th_1p4(j)
            soft_bits02(i,j)=2;
        elseif -th_1p4(j)<=soft_tmp(i,j) && soft_tmp(i,j)<0
            soft_bits02(i,j)=3;
        elseif 0<=soft_tmp(i,j) && soft_tmp(i,j)<th_1p4(j)
            soft_bits02(i,j)=4;
        elseif th_1p4(j)<=soft_tmp(i,j) && soft_tmp(i,j)<th_2p4(j)
            soft_bits02(i,j)=5;
        elseif th_2p4(j)<=soft_tmp(i,j) && soft_tmp(i,j)<th_3p4(j)
            soft_bits02(i,j)=6;
        elseif th_3p4(j)<=soft_tmp(i,j)
            soft_bits02(i,j)=7;
        end
    end
end
th_1p25=chan_amp/10^0.5*1.25;
th_1p5=chan_amp/10^0.5*1.5;
th_1p75=chan_amp/10^0.5*1.75;
th_2p0=chan_amp/10^0.5*2.0;
th_2p25=chan_amp/10^0.5*2.25;
th_2p5=chan_amp/10^0.5*2.5;
th_2p75=chan_amp/10^0.5*2.75;
for i=1:size(soft_tmp,1)
    for j=1:size(soft_tmp,2)
        if abs(soft_tmp(i,j))<th_1p25(j)
            soft_bits13(i,j)=7;
        elseif th_1p25(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_1p5(j)
            soft_bits13(i,j)=6;
        elseif th_1p5(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_1p75(j)
            soft_bits13(i,j)=5;
        elseif th_1p75(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_2p0(j)
            soft_bits13(i,j)=4;
        elseif th_2p0(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_2p25(j)
            soft_bits13(i,j)=3;
        elseif th_2p25(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_2p5(j)
            soft_bits13(i,j)=2;
        elseif th_2p5(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_2p75(j)
            soft_bits13(i,j)=1;
        elseif th_2p75(j)<=abs(soft_tmp(i,j))
            soft_bits13(i,j)=0;
        end
    end
end
soft_bits([1,3],:)=soft_bits02;
soft_bits([2,4],:)=soft_bits13;

evm_real=zeros(1,length(rx_symbols));
evm_image=zeros(1,length(rx_symbols));
rx_symbols_nom=rx_symbols./chan_amp;
for i=1:length(rx_symbols)
    soft_bits_i=soft_bits(:,i)>=4;
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

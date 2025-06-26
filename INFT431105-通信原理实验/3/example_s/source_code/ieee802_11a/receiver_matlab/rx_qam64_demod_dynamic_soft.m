function [soft_bits,evm] = rx_qam64_demod_dynamic_soft(rx_symbols,chan_amp)

soft_bits = zeros(6,length(rx_symbols));  % Each symbol consists of 6 bits
soft_tmp(1,:)=real(rx_symbols);
soft_tmp(2,:)=imag(rx_symbols);
th_1p4=chan_amp/42^0.5*0.25;
th_2p4=chan_amp/42^0.5*0.5;
th_3p4=chan_amp/42^0.5*0.75;
for i=1:size(soft_tmp,1)
    for j=1:size(soft_tmp,2)
        if soft_tmp(i,j)<-th_3p4(j)
            soft_bits03(i,j)=0;
        elseif -th_3p4(j)<=soft_tmp(i,j) && soft_tmp(i,j)<-th_2p4(j)
            soft_bits03(i,j)=1;
        elseif -th_2p4(j)<=soft_tmp(i,j) && soft_tmp(i,j)<-th_1p4(j)
            soft_bits03(i,j)=2;
        elseif -th_1p4(j)<=soft_tmp(i,j) && soft_tmp(i,j)<0
            soft_bits03(i,j)=3;
        elseif 0<=soft_tmp(i,j) && soft_tmp(i,j)<th_1p4(j)
            soft_bits03(i,j)=4;
        elseif th_1p4(j)<=soft_tmp(i,j) && soft_tmp(i,j)<th_2p4(j)
            soft_bits03(i,j)=5;
        elseif th_2p4(j)<=soft_tmp(i,j) && soft_tmp(i,j)<th_3p4(j)
            soft_bits03(i,j)=6;
        elseif th_3p4(j)<=soft_tmp(i,j)
            soft_bits03(i,j)=7;
        end
    end
end
th_3p25=chan_amp/42^0.5*3.25;
th_3p5=chan_amp/42^0.5*3.5;
th_3p75=chan_amp/42^0.5*3.75;
th_4p0=chan_amp/42^0.5*4.0;
th_4p25=chan_amp/42^0.5*4.25;
th_4p5=chan_amp/42^0.5*4.5;
th_4p75=chan_amp/42^0.5*4.75;
for i=1:size(soft_tmp,1)
    for j=1:size(soft_tmp,2)
        if abs(soft_tmp(i,j))<th_3p25(j)
            soft_bits14(i,j)=7;
        elseif th_3p25(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_3p5(j)
            soft_bits14(i,j)=6;
        elseif th_3p5(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_3p75(j)
            soft_bits14(i,j)=5;
        elseif th_3p75(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_4p0(j)
            soft_bits14(i,j)=4;
        elseif th_4p0(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_4p25(j)
            soft_bits14(i,j)=3;
        elseif th_4p25(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_4p5(j)
            soft_bits14(i,j)=2;
        elseif th_4p5(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_4p75(j)
            soft_bits14(i,j)=1;
        elseif th_4p75(j)<=abs(soft_tmp(i,j))
            soft_bits14(i,j)=0;
        end
    end
end
th_1p25=chan_amp/42^0.5*1.25;
th_1p5=chan_amp/42^0.5*1.5;
th_1p75=chan_amp/42^0.5*1.75;
th_2p0=chan_amp/42^0.5*2.0;
th_2p25=chan_amp/42^0.5*2.25;
th_2p5=chan_amp/42^0.5*2.5;
th_2p75=chan_amp/42^0.5*2.75;

th_5p25=chan_amp/42^0.5*5.25;
th_5p5=chan_amp/42^0.5*5.5;
th_5p75=chan_amp/42^0.5*5.75;
th_6p0=chan_amp/42^0.5*6.0;
th_6p25=chan_amp/42^0.5*6.25;
th_6p5=chan_amp/42^0.5*6.5;
th_6p75=chan_amp/42^0.5*6.75;
for i=1:size(soft_tmp,1)
    for j=1:size(soft_tmp,2)
        if abs(soft_tmp(i,j))<th_1p25(j)
            soft_bits25(i,j)=0;
        elseif th_1p25(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_1p5(j)
            soft_bits25(i,j)=1;
        elseif th_1p5(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_1p75(j)
            soft_bits25(i,j)=2;
        elseif th_1p75(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_2p0(j)
            soft_bits25(i,j)=3;
        elseif th_2p0(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_2p25(j)
            soft_bits25(i,j)=4;
        elseif th_2p25(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_2p5(j)
            soft_bits25(i,j)=5;
        elseif th_2p5(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_2p75(j)
            soft_bits25(i,j)=6;
        elseif th_2p75(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_5p25(j)
            soft_bits25(i,j)=7;
        elseif abs(soft_tmp(i,j))>=th_5p25(j) && abs(soft_tmp(i,j))<th_5p5(j)
            soft_bits25(i,j)=6;
        elseif th_5p5(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_5p75(j)
            soft_bits25(i,j)=5;
        elseif th_5p75(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_6p0(j)
            soft_bits25(i,j)=4;
        elseif th_6p0(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_6p25(j)
            soft_bits25(i,j)=3;
        elseif th_6p25(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_6p5(j)
            soft_bits25(i,j)=2;
        elseif th_6p5(j)<=abs(soft_tmp(i,j)) && abs(soft_tmp(i,j))<th_6p75(j)
            soft_bits25(i,j)=1;
        elseif th_6p75(j)<=abs(soft_tmp(i,j))
            soft_bits25(i,j)=0;
        end
    end
end
soft_bits([1,4],:)=soft_bits03;
soft_bits([2,5],:)=soft_bits14;
soft_bits([3,6],:)=soft_bits25;

evm_real=zeros(1,length(rx_symbols));
evm_image=zeros(1,length(rx_symbols));
rx_symbols_nom=rx_symbols./chan_amp;
for i=1:length(rx_symbols)
    soft_bits_i=soft_bits(:,i)>=4;
    if(soft_bits_i==[0;0;0;1;0;0])
        evm_real(i)=real(rx_symbols_nom(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-7/sqrt(42);
    elseif(soft_bits_i==[0;0;1;1;0;0])
        evm_real(i)=real(rx_symbols_nom(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-7/sqrt(42);
    elseif(soft_bits_i==[0;1;1;1;0;0])
        evm_real(i)=real(rx_symbols_nom(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-7/sqrt(42);
    elseif(soft_bits_i==[0;1;0;1;0;0])
        evm_real(i)=real(rx_symbols_nom(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-7/sqrt(42);
    elseif(soft_bits_i==[1;1;0;1;0;0])
        evm_real(i)=real(rx_symbols_nom(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-7/sqrt(42);
    elseif(soft_bits_i==[1;1;1;1;0;0])
        evm_real(i)=real(rx_symbols_nom(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-7/sqrt(42);
    elseif(soft_bits_i==[1;0;1;1;0;0])
        evm_real(i)=real(rx_symbols_nom(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-7/sqrt(42);
    elseif(soft_bits_i==[1;0;0;1;0;0])
        evm_real(i)=real(rx_symbols_nom(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-7/sqrt(42);
    elseif(soft_bits_i==[0;0;0;1;0;1])
        evm_real(i)=real(rx_symbols_nom(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-5/sqrt(42);
    elseif(soft_bits_i==[0;0;1;1;0;1])
        evm_real(i)=real(rx_symbols_nom(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-5/sqrt(42);
    elseif(soft_bits_i==[0;1;1;1;0;1])
        evm_real(i)=real(rx_symbols_nom(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-5/sqrt(42);
    elseif(soft_bits_i==[0;1;0;1;0;1])
        evm_real(i)=real(rx_symbols_nom(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-5/sqrt(42);
    elseif(soft_bits_i==[1;1;0;1;0;1])
        evm_real(i)=real(rx_symbols_nom(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-5/sqrt(42);
    elseif(soft_bits_i==[1;1;1;1;0;1])
        evm_real(i)=real(rx_symbols_nom(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-5/sqrt(42);
    elseif(soft_bits_i==[1;0;1;1;0;1])
        evm_real(i)=real(rx_symbols_nom(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-5/sqrt(42);
    elseif(soft_bits_i==[1;0;0;1;0;1])
        evm_real(i)=real(rx_symbols_nom(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-5/sqrt(42);
    elseif(soft_bits_i==[0;0;0;1;1;1])
        evm_real(i)=real(rx_symbols_nom(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-3/sqrt(42);
    elseif(soft_bits_i==[0;0;1;1;1;1])
        evm_real(i)=real(rx_symbols_nom(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-3/sqrt(42);
    elseif(soft_bits_i==[0;1;1;1;1;1])
        evm_real(i)=real(rx_symbols_nom(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-3/sqrt(42);
    elseif(soft_bits_i==[0;1;0;1;1;1])
        evm_real(i)=real(rx_symbols_nom(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-3/sqrt(42);
    elseif(soft_bits_i==[1;1;0;1;1;1])
        evm_real(i)=real(rx_symbols_nom(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-3/sqrt(42);
    elseif(soft_bits_i==[1;1;1;1;1;1])
        evm_real(i)=real(rx_symbols_nom(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-3/sqrt(42);
    elseif(soft_bits_i==[1;0;1;1;1;1])
        evm_real(i)=real(rx_symbols_nom(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-3/sqrt(42);
    elseif(soft_bits_i==[1;0;0;1;1;1])
        evm_real(i)=real(rx_symbols_nom(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-3/sqrt(42);
    elseif(soft_bits_i==[0;0;0;1;1;0])
        evm_real(i)=real(rx_symbols_nom(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-1/sqrt(42);
    elseif(soft_bits_i==[0;0;1;1;1;0])
        evm_real(i)=real(rx_symbols_nom(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-1/sqrt(42);
    elseif(soft_bits_i==[0;1;1;1;1;0])
        evm_real(i)=real(rx_symbols_nom(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-1/sqrt(42);
    elseif(soft_bits_i==[0;1;0;1;1;0])
        evm_real(i)=real(rx_symbols_nom(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-1/sqrt(42);
    elseif(soft_bits_i==[1;1;0;1;1;0])
        evm_real(i)=real(rx_symbols_nom(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-1/sqrt(42);
    elseif(soft_bits_i==[1;1;1;1;1;0])
        evm_real(i)=real(rx_symbols_nom(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-1/sqrt(42);
    elseif(soft_bits_i==[1;0;1;1;1;0])
        evm_real(i)=real(rx_symbols_nom(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-1/sqrt(42);
    elseif(soft_bits_i==[1;0;0;1;1;0])
        evm_real(i)=real(rx_symbols_nom(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))-1/sqrt(42);
    elseif(soft_bits_i==[0;0;0;0;1;0])
        evm_real(i)=real(rx_symbols_nom(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+1/sqrt(42);
    elseif(soft_bits_i==[0;0;1;0;1;0])
        evm_real(i)=real(rx_symbols_nom(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+1/sqrt(42);
    elseif(soft_bits_i==[0;1;1;0;1;0])
        evm_real(i)=real(rx_symbols_nom(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+1/sqrt(42);
    elseif(soft_bits_i==[0;1;0;0;1;0])
        evm_real(i)=real(rx_symbols_nom(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+1/sqrt(42);
    elseif(soft_bits_i==[1;1;0;0;1;0])
        evm_real(i)=real(rx_symbols_nom(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+1/sqrt(42);
    elseif(soft_bits_i==[1;1;1;0;1;0])
        evm_real(i)=real(rx_symbols_nom(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+1/sqrt(42);
    elseif(soft_bits_i==[1;0;1;0;1;0])
        evm_real(i)=real(rx_symbols_nom(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+1/sqrt(42);
    elseif(soft_bits_i==[1;0;0;0;1;0])
        evm_real(i)=real(rx_symbols_nom(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+1/sqrt(42);
    elseif(soft_bits_i==[0;0;0;0;1;1])
        evm_real(i)=real(rx_symbols_nom(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+3/sqrt(42);
    elseif(soft_bits_i==[0;0;1;0;1;1])
        evm_real(i)=real(rx_symbols_nom(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+3/sqrt(42);
    elseif(soft_bits_i==[0;1;1;0;1;1])
        evm_real(i)=real(rx_symbols_nom(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+3/sqrt(42);
    elseif(soft_bits_i==[0;1;0;0;1;1])
        evm_real(i)=real(rx_symbols_nom(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+3/sqrt(42);
    elseif(soft_bits_i==[1;1;0;0;1;1])
        evm_real(i)=real(rx_symbols_nom(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+3/sqrt(42);
    elseif(soft_bits_i==[1;1;1;0;1;1])
        evm_real(i)=real(rx_symbols_nom(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+3/sqrt(42);
    elseif(soft_bits_i==[1;0;1;0;1;1])
        evm_real(i)=real(rx_symbols_nom(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+3/sqrt(42);
    elseif(soft_bits_i==[1;0;0;0;1;1])
        evm_real(i)=real(rx_symbols_nom(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+3/sqrt(42);
    elseif(soft_bits_i==[0;0;0;0;0;1])
        evm_real(i)=real(rx_symbols_nom(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+5/sqrt(42);
    elseif(soft_bits_i==[0;0;1;0;0;1])
        evm_real(i)=real(rx_symbols_nom(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+5/sqrt(42);
    elseif(soft_bits_i==[0;1;1;0;0;1])
        evm_real(i)=real(rx_symbols_nom(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+5/sqrt(42);
    elseif(soft_bits_i==[0;1;0;0;0;1])
        evm_real(i)=real(rx_symbols_nom(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+5/sqrt(42);
    elseif(soft_bits_i==[1;1;0;0;0;1])
        evm_real(i)=real(rx_symbols_nom(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+5/sqrt(42);
    elseif(soft_bits_i==[1;1;1;0;0;1])
        evm_real(i)=real(rx_symbols_nom(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+5/sqrt(42);
    elseif(soft_bits_i==[1;0;1;0;0;1])
        evm_real(i)=real(rx_symbols_nom(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+5/sqrt(42);
    elseif(soft_bits_i==[1;0;0;0;0;1])
        evm_real(i)=real(rx_symbols_nom(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+5/sqrt(42);
    elseif(soft_bits_i==[0;0;0;0;0;0])
        evm_real(i)=real(rx_symbols_nom(i))+7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+7/sqrt(42);
    elseif(soft_bits_i==[0;0;1;0;0;0])
        evm_real(i)=real(rx_symbols_nom(i))+5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+7/sqrt(42);
    elseif(soft_bits_i==[0;1;1;0;0;0])
        evm_real(i)=real(rx_symbols_nom(i))+3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+7/sqrt(42);
    elseif(soft_bits_i==[0;1;0;0;0;0])
        evm_real(i)=real(rx_symbols_nom(i))+1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+7/sqrt(42);
    elseif(soft_bits_i==[1;1;0;0;0;0])
        evm_real(i)=real(rx_symbols_nom(i))-1/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+7/sqrt(42);
    elseif(soft_bits_i==[1;1;1;0;0;0])
        evm_real(i)=real(rx_symbols_nom(i))-3/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+7/sqrt(42);
    elseif(soft_bits_i==[1;0;1;0;0;0])
        evm_real(i)=real(rx_symbols_nom(i))-5/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+7/sqrt(42);
    else
        evm_real(i)=real(rx_symbols_nom(i))-7/sqrt(42);
        evm_image(i)=imag(rx_symbols_nom(i))+7/sqrt(42);
    end

end

evm=(evm_real.^2+evm_image.^2).^0.5;
evm=sum(evm)/length(evm);


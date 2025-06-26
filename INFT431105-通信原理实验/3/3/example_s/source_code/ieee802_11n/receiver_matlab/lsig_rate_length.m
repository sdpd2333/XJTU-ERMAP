function [rate,length,error]=lsig_rate_length(signal)
error=0;
ecc=signal(1);
for i=2:17
    ecc=xor(ecc,signal(i));
end
if(signal(18)==ecc)
    if(signal(1:4)==[1 1 0 1])
        rate=6; 
    else
        disp('Error data_rate');
        rate=0;
        error=1;
    end
    length=bin2dec(num2str(signal(17:-1:6)));  
else
    disp('Error signal');
    rate=0;
    length=0;
    error=1;
end

    
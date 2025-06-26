function [Bit,stateo]=demod_dbpsk2(signal,statei)

signal=signal.*exp(-1i*pi/4);
CONST=0.2;
if real(signal)>CONST
    d = 0;
else
    
    d = 1;
end
  
Bit = xor(d,statei);
stateo = d;

end


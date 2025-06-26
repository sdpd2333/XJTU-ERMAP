function [Bibit,stateo] = demod_dqpsk(signal,statei)

signal=signal.*exp(-1i*pi/4);
CONST=0.3;
if real(signal)>=CONST    
    d=0;
elseif real(signal)<=-CONST
    d=2;
elseif imag(signal)>=CONST
    d=1;
elseif imag(signal)<=-CONST 
    d=3;
end
   
e=mod(d-statei,4);
stateo=d;
    
switch e
    case 0,    Bibit=[0 0];
    case 1,    Bibit=[0 1];
    case 2,    Bibit=[1 1];
    otherwise, Bibit=[1 0];
end

end

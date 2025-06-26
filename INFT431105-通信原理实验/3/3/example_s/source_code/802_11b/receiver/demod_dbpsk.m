function [Bit, In, stateo]=demod_dbpsk(signal,statei,DEC_MET)
CONST=DEC_MET;
A = [1 -1 1 1 -1 1 1 1 -1 -1 -1];
signal=signal.*exp(-1i*pi/4);
I = signal(1,:)*A';
if abs(I)<CONST
    In = 1;
    Bit = -1;
    stateo=statei;
else
    if I > 0
        d = 0;
    else
        d = 1;
    end
    In = 11;
    Bit = xor(d,statei);
    stateo = d;
end

end



function OfdmSymb = OfdmSignalDemodulation(ModOfdmSymbWithCP, ...
                                NumFFT, NumCP, NumDataCarrier)

ModOfdmSymb = ModOfdmSymbWithCP(NumCP+1:end, :);

OfdmSymbFFT = fft(ModOfdmSymb) / sqrt(NumFFT);
DemodOfdmSymb = [ ...
    OfdmSymbFFT(NumFFT/2+1:end, :);
    OfdmSymbFFT(1:NumFFT/2, :)];
OfdmSymb = [ ...
    DemodOfdmSymb(NumFFT/2-NumDataCarrier/2+1:NumFFT/2, :);
    DemodOfdmSymb(NumFFT/2+2:NumFFT/2+NumDataCarrier/2+1, :)];


function OfdmSymbWithCP = OfdmSignalModulation(Bits, NumFFT, NumCP)
% Symbol mapping: BPSK
BpskModObj = comm.BPSKModulator('PhaseOffset', pi/4);

NumOfdmSymb = size(Bits, 2);
MapSymb = zeros(size(Bits));
for idx = 1:NumOfdmSymb
    MapSymb(:, idx) = step(BpskModObj,Bits(:, idx));
end

MapFft = [ ...
    zeros(NumFFT/2-length(MapSymb)/2, NumOfdmSymb);
    MapSymb(1:end/2, :);
    zeros(1, NumOfdmSymb);
    MapSymb(end/2+1:end, :);
    zeros(NumFFT/2-length(MapSymb)/2-1, NumOfdmSymb)];

ReMapFft = [ ...
    MapFft(NumFFT/2+1:end, :);
    MapFft(1:NumFFT/2, :)];

OfdmSymb = ifft(ReMapFft) * sqrt(NumFFT);

OfdmSymbWithCP = [ ...
    OfdmSymb(NumFFT-NumCP+1:end, :);
    OfdmSymb];

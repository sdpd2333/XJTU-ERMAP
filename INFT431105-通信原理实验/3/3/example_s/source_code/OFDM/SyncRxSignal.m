
function startIdx = SyncRxSignal(rxSig, overSampFactor, numFFT)
numFFTExt = numFFT * overSampFactor;
BpskModObj = comm.BPSKModulator('PhaseOffset', pi/4);

syncBits = GetSyncBits();
syncSymb = step(BpskModObj,syncBits);
syncSymbExt = [ 0;
                syncSymb(end/2+1:end);
                zeros(numFFTExt-length(syncSymb)-1, 1);
                syncSymb(1:end/2)];

syncSig = ifft(syncSymbExt) * sqrt(length(syncSymbExt));
syncSig(65:end)=[];
numXCorr = length(rxSig)*3/4 - length(syncSig) - 1;
xCorrRxSig = zeros(numXCorr, 1);
for idx = 1:numXCorr
    xCorrRxSig(idx) = syncSig' * rxSig(idx:idx+length(syncSig)-1);
end
subplot(221);plot(abs(xCorrRxSig));title('sync plot');
[~, startIdx] = max(abs(xCorrRxSig));
disp(['startIdx=',num2str(startIdx)]);
startIdx = startIdx - overSampFactor*64;

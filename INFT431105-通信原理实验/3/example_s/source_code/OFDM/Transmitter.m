function tx_signal2 = Transmitter(upsample)
NumFFT = 128;
NumSyncPreamble = 32;
NumCP = 16;
%% Transmitter
% Generate synchronization symbols
SyncBits = GetSyncBits();
SyncOfdmSymb = OfdmSignalModulation(SyncBits, NumFFT, 0);

% Generate pilot symbols
PilotBits = GetPilotBits();
TxPilotOfdmSymb = OfdmSignalModulation(PilotBits, NumFFT, 0);

% Generate data symbols
TxDataBits = GetDataBits();
TxDataOfdmSymbMtx = OfdmSignalModulation(TxDataBits, NumFFT, NumCP);
TxDataOfdmSymb = reshape(TxDataOfdmSymbMtx, [], 1);

% Reconstruct transmission signal
TxSignal = [ ...
    SyncOfdmSymb(1:NumSyncPreamble);
    SyncOfdmSymb(1:NumSyncPreamble);
    SyncOfdmSymb;
    TxPilotOfdmSymb;
    TxPilotOfdmSymb;
    TxDataOfdmSymb];
flt1=rcosine(1,upsample,'fir/sqrt',0.05,64);
tx_signal2=rcosflt(TxSignal,1,upsample, 'filter', flt1);
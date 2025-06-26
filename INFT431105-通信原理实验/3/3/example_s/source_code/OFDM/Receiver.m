function RxDataBits = Receiver(RxSignal)

% Setting parameters
NumFFT = 128;
NumSyncPreamble = 32;
NumCP = 16;
NumDataOfdmSymb = 18;
NumDataSubcarrier = 108;
RxSignalExt(:,1)=RxSignal;
figure(2);clf;
%% Receiver
NumSyncSymb = NumSyncPreamble*2 + NumFFT;
NumPilotSymb = NumFFT * 2;
NumDataSymb = (NumFFT+NumCP) * NumDataOfdmSymb;
NumRadioFrame = NumSyncSymb + NumPilotSymb + NumDataSymb;

StartIdx = SyncRxSignalImproved1(RxSignalExt, 1, NumFFT);
RxSignalRadioFrame = RxSignalExt(StartIdx:StartIdx+NumRadioFrame-1);

% Pilot OFDM symbol
PilotOfdmSymb = reshape(RxSignalRadioFrame(NumSyncSymb+1:NumSyncSymb+NumPilotSymb), [], 2);

%% Demodulation
% Estimate carrier frequency offset
RxPilotSymb = OfdmSignalDemodulation(PilotOfdmSymb, NumFFT, 0, NumDataSubcarrier);
XCorrPilot = RxPilotSymb(:,1)' * RxPilotSymb(:,2);
EpsEst = 1/(2*pi) * atan(imag(XCorrPilot)/real(XCorrPilot));

% Estimate carrier freqnecy offset
RxSigalRadioFrameCmpCFO = RxSignalRadioFrame .* ...
    exp(-1j*2*pi*EpsEst/NumFFT * (0:length(RxSignalRadioFrame)-1)');

% Reobtain pilot data
PilotOfdmSymb = reshape( ...
    RxSigalRadioFrameCmpCFO(NumSyncSymb+1:NumSyncSymb+NumPilotSymb), [], 2);
% Data OFDM symbol
DataOfdmSymb = reshape( ...
    RxSigalRadioFrameCmpCFO(NumSyncSymb+NumPilotSymb+1:end), ...
    [], NumDataOfdmSymb);

RxPilotSymb = OfdmSignalDemodulation(PilotOfdmSymb, NumFFT, 0, NumDataSubcarrier);
RxDataSymb = OfdmSignalDemodulation(DataOfdmSymb, NumFFT, NumCP, NumDataSubcarrier);

% Channel estimation and equalization
BpskModObj = comm.BPSKModulator('PhaseOffset', pi/4);
PilotBits = GetPilotBits();
TxPilotSymb = step(BpskModObj,PilotBits);
ChanEst = RxPilotSymb(:,1) ./ TxPilotSymb;
RxDataSymbEq = RxDataSymb ./ repmat(ChanEst, 1, NumDataOfdmSymb);
subplot(222);plot(10*log10(abs(ChanEst).^2)-min(10*log10(abs(ChanEst).^2)));title('channel estimation');
subplot(223);plot(RxDataSymb(:),'*');axis equal;title('');title('scattor before equalization');axis square;
subplot(224);plot(RxDataSymbEq(:).*exp(-1i*pi/4),'.');axis([-1.5,1.5,-1.5,1.5]);title('scattor after equalization'); axis square;
% Demodulation
BpskDemodulatorObj = comm.BPSKDemodulator( ...
    'PhaseOffset', pi/4, ...
    'DecisionMethod', 'Hard decision');
RxDataBits = zeros(size(RxDataSymbEq));
for idx = 1:NumDataOfdmSymb
    RxDataBits(:,idx) = step(BpskDemodulatorObj,RxDataSymbEq(:,idx));
end

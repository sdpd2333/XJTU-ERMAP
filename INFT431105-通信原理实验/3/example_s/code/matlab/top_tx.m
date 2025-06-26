clearvars -except times;close all;warning off;
save_file=0;
send_yunsdr=1;
source='2ASK';% [tone ieee802_11a ieee802_11n]
yunsdr_init.ipaddr='192.168.1.10';
switch source
    case 'tone'
        addpath source_code\Tone
        txdata = tone_tx_func();
        yunsdr_init.txgap=0;
    case 'ieee802_11a'
        addpath source_code\ieee802_11a\transmitter_matlab
        in_byte=repmat([1:100],1,10);
        rate=54;
        upsample=2;
        tx_11a=ieee802_11a_tx_func(in_byte,rate,upsample);
%         txdata=repmat([zeros(size(tx_11a));tx_11a],1,1);
        yunsdr_init.txgap=10e3;
        txdata=tx_11a;
    case 'ieee802_11n'
        addpath source_code\ieee802_11n\transmitter_matlab
% %         in_byte=1:96;
        in_byte=repmat([1:100],1,10);
        mcs=13;
        upsample=2;
        tx_11n=ieee802_11n_tx_func(in_byte,mcs,upsample);
%         txdata=repmat([zeros(size(tx_11n));tx_11n],1,1);
        txdata=tx_11n;
        yunsdr_init.txgap=10e3;
    case '2ASK'
        addpath source_code\2ASK
        frame_len = 100;
        txdata = ask2_tx_func(frame_len);
        yunsdr_init.txgap=0;
    case '4ASK'
        addpath source_code\4ASK
        frame_len = 100;
        txdata = ask4_tx_func(frame_len);
        yunsdr_init.txgap=0;
    case '2FSK'
        addpath source_code\2FSK
        frame_len = 100;
        txdata = fsk2_tx_func(frame_len);
        yunsdr_init.txgap=0;
    case '2PSK'
        addpath source_code\2PSK
        frame_len = 100;
        txdata = psk2_tx_func(frame_len);
        yunsdr_init.txgap=0;
    case 'BPSK'
        addpath source_code\BPSK\transmitter
        txdata = bpsk_tx_func;
        yunsdr_init.txgap=0;
    case 'QPSK'
        addpath source_code\QPSK\transmitter
        frame_len = 1000;
        txdata = qpsk_tx_func;
        yunsdr_init.txgap=0;
    case '16QAM'
        addpath source_code\16QAM\transmitter
        txdata = qam16_tx_func;
        yunsdr_init.txgap=0;
    case '64QAM'
        addpath source_code\64QAM\transmitter
        txdata = qam64_tx_func;
        yunsdr_init.txgap=5e3;
    case 'OFDM'
        addpath source_code\OFDM
        upsample=4;
        txdata = Transmitter(upsample);
        yunsdr_init.txgap=3e4;
    case 'SCFDE'
        addpath source_code\SCFDE\transmitter
        txdata = scfde_tx_func();
        yunsdr_init.txgap=1e5;
    case '11b'
        addpath source_code\802_11b\transmitter
        txdata = ieee802_11b_tx_func(1, 50, 1);
        yunsdr_init.txgap=0;   
end
%% save to file
if save_file==1
    ret=save_to_file(txdata,1);
end
%% send to yunsdr
if send_yunsdr==1
    yunsdr_init.samp=40e6;                  % sample freq 4e6~61.44e6
    yunsdr_init.bw=20e6;                    % tx analog flter  bandwidth 250e3~56e6
    yunsdr_init.freq=2500e6;                % tx LO freq 70e6~6000e6
    yunsdr_init.tx_att1=20e3;               % tx att ch1 0~89e3 mdB
    yunsdr_init.tx_att2=20e3;               % tx att ch2 0~89e3 mdB
    yunsdr_init.fdd_tdd='FDD';              % FDD,TDD
    yunsdr_init.trx_sw='TX';                % TX,RX
    yunsdr_init.tx_chan='TX_DUALCHANNEL';      % TX1_CHANNEL,TX2_CHANNEL,TX_DUALCHANNEL
    yunsdr_init.ref='INTERNAL_REFERENCE';   % INTERNAL_REFERENCE,EXTERNAL_REFERENCE
    yunsdr_init.vco_cal='AUXDAC1';          % AUXDAC1 ADF4001
    yunsdr_init.aux_dac1=0;                 % Voltage to change freq of vctcxo 0~3000mv 
    % ***************tx mode*************** %
    % START_TX_NORMAL stream mode tx send immediately without timestamp
    % START_TX_LOOP   LOOP mode tx send loop and loop without timestamp
    % START_TX_BURST  Burst mode tx send until systime count to timestamp
    % txgap in START_TX_NORMAL and START_TX_LOOP mode is gap nanosecond
    % txgap in START_TX_BURST mode  txtime = read systime + txgap(nanosecond)
    yunsdr_init.txmode='START_TX_LOOP';
    
    % ************timestamp mode************ %
    % PPS_ALL_DISABLE pps disable
    % PPS_INTERNAL_EN pps from internal gps module
    % PPS_EXTERNAL_EN pps from external pps in port
    yunsdr_init.ppsmode='PPS_ALL_DISABLE';   % PPS
    % ************************************** %
    
    if size(txdata,2)>2
        disp(['txdata is ',num2str(size(txdata,2)),' stream, has exceed 2 max!']);
        return;
    else
        ret=send_to_yunsdr(txdata,yunsdr_init);
    end
end
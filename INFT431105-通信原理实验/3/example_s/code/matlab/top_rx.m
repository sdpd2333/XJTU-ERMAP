clearvars -except times;close all;warning off;
source='yunsdr';% file or yunsdr
data_type='tone';
yunsdr_init.ipaddr='192.168.1.10';
yunsdr_init.rxsamples=1e4; % receive data in samples
if ~isempty(strfind(source, 'file'))
%% load from file
    rxdata=load_from_file;
else
%% load from yunsdr
    yunsdr_init.samp=40e6;                  % sample freq 4e6~61.44e6
    yunsdr_init.bw=20e6;                    % rx analog flter bandwidth 250e3~56e6
    yunsdr_init.freq=2500e6;                % rx LO freq 70e6~6000e6
    yunsdr_init.rxgain_mode1='RF_GAIN_SLOWATTACK_AGC'; % RF_GAIN_MGC,RF_GAIN_FASTATTACK_AGC,RF_GAIN_SLOWATTACK_AGC
    yunsdr_init.rxgain_mode2='RF_GAIN_MGC'; % RF_GAIN_MGC,RF_GAIN_FASTATTACK_AGC,RF_GAIN_SLOWATTACK_AGC
    yunsdr_init.rxgain1=10;                  % rx mgc gain ch1 0~70
    yunsdr_init.rxgain2=5;                  % rx mgc gain ch2 0~70
    yunsdr_init.fdd_tdd='FDD';              % FDD,TDD
    yunsdr_init.trx_sw='RX';                % TX,RX
    yunsdr_init.rx_chan='RX_DUALCHANNEL';   % RX1_CHANNEL,RX2_CHANNEL,RX_DUALCHANNEL
    yunsdr_init.ref='INTERNAL_REFERENCE';   % INTERNAL_REFERENCE,EXTERNAL_REFERENCE
    yunsdr_init.vco_cal='AUXDAC1';          % AUXDAC1 ADF4001
    yunsdr_init.aux_dac1=0;                 % Voltage to change freq of vctcxo 0~3000mv
    % ***************tx mode*************** %
    % START_RX_BULK   rx without timestamp
    % START_RX_BURST  rx at systime count to timestamp
    yunsdr_init.rxmode='START_RX_BULK';
    % ************timestamp mode************ %
    % PPS_ALL_DISABLE pps disable
    % PPS_INTERNAL_EN pps from internal gps module
    % PPS_EXTERNAL_EN pps from external pps in port
    yunsdr_init.ppsmode='PPS_ALL_DISABLE';   % PPS
    % ************************************** %
    
end
switch data_type
    case 'tone'
        [rxdata]=load_from_yunsdr(yunsdr_init);
        addpath source_code\Tone
        tone_rx_func(rxdata,yunsdr_init.samp);
        pause(0.1);
    case 'ieee802_11a'
        [rxdata]=load_from_yunsdr(yunsdr_init);
        upsample=2;
        addpath source_code\ieee802_11a\receiver_matlab
%         rxdata=add_user_channel(rxdata,156e3,30,upsample);
        [data_byte_recv,sim_options] = ieee802_11a_rx_func(rxdata(:,1),upsample);
    case 'ieee802_11n'
        [rxdata]=load_from_yunsdr(yunsdr_init);
        upsample=2;
        addpath source_code\ieee802_11n\receiver_matlab
        [data_byte_recv,sim_options] = ieee802_11n_rx_func(rxdata,upsample);
    case '2ASK'
        addpath source_code\2ASK
        while(1)
            [rxdata]=load_from_yunsdr(yunsdr_init);
            rxdata = rxdata(:,1);
            ask2_rx_func(rxdata);
            pause(0.1);
            break;
        end
    case '4ASK'
        addpath source_code\4ASK
        while(1)
            [rxdata]=load_from_yunsdr(yunsdr_init);
            rxdata = rxdata(:,1);
            ask4_rx_func(rxdata);
            pause(0.1);
            break;
        end
    case '2FSK'
        while(1)
            addpath source_code\2FSK
            [rxdata]=load_from_yunsdr(yunsdr_init);
            rxdata = rxdata(:,1);
            fsk2_rx_func(rxdata);
            pause(0.1);
            break;
        end
    case '2PSK'
        addpath source_code\2PSK
        while(1)
            [rxdata]=load_from_yunsdr(yunsdr_init);
            rxdata = rxdata(:,1);
            psk2_rx_func(rxdata);
            pause(0.1);
            break;
        end
    case 'BPSK'
        addpath source_code\BPSK\receiver
        while(1)
            [rxdata]=load_from_yunsdr(yunsdr_init);
            rxdata = rxdata(:,1);
            bpsk_rx_func(rxdata);
            pause(0.1);
%             break;
        end
    case 'QPSK'
        addpath source_code\QPSK\receiver
        while(1)
            [rxdata]=load_from_yunsdr(yunsdr_init);
            rxdata = rxdata(:,1);
            qpsk_rx_func(rxdata);
            pause(0.1);
%             break;
        end
    case '16QAM'
        addpath source_code\16QAM\receiver
        while(1)
            [rxdata]=load_from_yunsdr(yunsdr_init);
            rxdata = rxdata(:,1);
            qam16_rx_func(rxdata);
            pause(0.1);
%             break;
        end
    case '64QAM'
        addpath source_code\64QAM\receiver
        while(1)
            [rxdata]=load_from_yunsdr(yunsdr_init);
            rxdata = rxdata(:,1);
            qam64_rx_func(rxdata);
            pause(0.1);
            break;
        end
    case 'OFDM'
        addpath source_code\OFDM
        while(1)
            [rxdata]=load_from_yunsdr(yunsdr_init);
            rxdata = rxdata(:,1);
            Receiver(rxdata(1:4:end));
        end
    case 'SCFDE'
        addpath source_code\SCFDE\receiver
        while(1)
            [rxdata]=load_from_yunsdr(yunsdr_init);
            rxdata = rxdata(:,1);
            scfde_rx_func(rxdata);
            pause(0.1);
%             break;
        end
    case '11b'
        addpath source_code\802_11b\receiver
        while(1)
            [rxdata]=load_from_yunsdr(yunsdr_init);
            ieee802_11b_rx_func(rxdata(:,1));
            pause(0.1);
            break;
        end
end
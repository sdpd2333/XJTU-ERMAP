function PLCP = tx_gen_plcp(sim_options)
if  sim_options.frame_type==1
    %% long frame PLCP preamble
    SYNC=ones(1,128);
    SFD=de2bi(hex2dec('f3a0'),16,'right-msb');
    PLCP_Preamble=[SYNC SFD];
elseif sim_options.frame_type==0
    %% short frame PLCP preamble
    SYNC=zeros(1,56);
    SFD=de2bi(hex2dec('05cf'),16,'right-msb');
    PLCP_Preamble=[SYNC SFD];
end
%% PLCP Header
if  sim_options.rate==1 && sim_options.frame_type==1
    SIGNAL=de2bi(hex2dec('0A'),8,'right-msb');
    SERVICE=[0 0 0 0 0 0 0 0];
    LENGTH=de2bi(sim_options.length*8,16,'right-msb');
elseif sim_options.rate==2
    SIGNAL=de2bi(hex2dec('14'),8,'right-msb');
    SERVICE=[0 0 0 0 0 0 0 0];
    LENGTH=de2bi(sim_options.length*4,16,'right-msb');
elseif sim_options.rate==5.5
    SIGNAL=de2bi(hex2dec('37'),8,'right-msb');
    SERVICE=[0 0 0 0 0 0 0 0];
    LENGTH=de2bi(ceil(sim_options.length*8/5.5),16,'right-msb');
elseif sim_options.rate==11
    SIGNAL=de2bi(hex2dec('6E'),8,'right-msb');
    LENGTH=de2bi(ceil(sim_options.length*8/11),16,'right-msb');
    if LENGTH-sim_options.length*8/11>=8/11
        SERVICE=[0 0 0 0 0 0 0 1];
    else
        SERVICE=[0 0 0 0 0 0 0 0];
    end
end

PLCP_CRC16 = crc16([SIGNAL SERVICE LENGTH]);
PLCP = [PLCP_Preamble,SIGNAL,SERVICE,LENGTH,PLCP_CRC16];
end
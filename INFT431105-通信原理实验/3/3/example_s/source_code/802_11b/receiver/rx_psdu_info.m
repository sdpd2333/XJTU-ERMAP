function [psdu,crc_32,frame_err] = rx_psdu_info(signal,state,si,data_rate,frame_type)
frame_err=0;
%% 1Mbps DBPSK
if data_rate==1
    State=state;
    m=0;
    %% demodulation and descramble
    for i=1:length(signal)
        [b,State]=demod_dbpsk2(signal(i),State);
        [c,si]=descramble(b,si);
        m=m+1;
        psdu(m)=c;  
    end  
%% 2Mbps DQPSK   
elseif data_rate==2
    if ~isempty(strfind(frame_type, 'long'))
        State=state*2;
    elseif ~isempty(strfind(frame_type, 'short'))
        State=state;
    end
    m=-1;
    for i=1:length(signal)
        [b,State]=demod_dqpsk(signal(i),State);
        [c,si]=descramble(b,si);
        m=m+2;
        psdu(m:m+1)=c;  
    end
elseif data_rate==5.5
     psdu = demod_cck55(signal);
end

%% crc32 check
ret2=crc32(psdu(1:length(psdu)-32)).';
crc_bits_32=psdu(length(psdu)-31:length(psdu));
crc_outputs2=sum(xor(ret2,crc_bits_32),2);
if crc_outputs2==0
    crc_32='YES';
else
    crc_32='NO';
    frame_err=frame_err+1;
end

end
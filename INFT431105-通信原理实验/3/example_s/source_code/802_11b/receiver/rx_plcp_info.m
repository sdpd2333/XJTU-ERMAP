function info_plcp = rx_plcp_info(signal,frame_type)

if ~isempty(strfind(frame_type, 'long'))
    len=192*11;
    gap=0;
    pass=0;
elseif ~isempty(strfind(frame_type, 'short'))
    len=96*11;
    gap=72;
    pass=96;
end

sig_plcp=signal(1:len);
%% analyze plcp header
[plcp,state,si] = rx_plcp_demod(sig_plcp);
%% plcp header
header=plcp(145-gap:end);
%% service
service=plcp(153-gap:160-gap);
%% signal
data_rate=bi2de(plcp(145-gap:152-gap),'right-msb')/10;
%% length
data_length=bi2de(plcp(161-gap:176-gap),'right-msb')/8.*data_rate;
%% crc16 check
ret_16=crc16(header(1:length(header)-16));
crc_bits_16=header(length(header)-15:length(header));
crc_outputs_16=sum(xor(ret_16,crc_bits_16),2);
if crc_outputs_16==0
    crc_16='YES';
else
    crc_16='NO';
end
%% modulate mode
if data_rate==1
    mod_way='DBPSK';
elseif data_rate==2
    mod_way='DQPSK';
elseif data_rate==5.5
    mod_way='5.5CCK';
elseif data_rate==11
    mod_way='11CCK';
end
%% frame index end
frame_index_end=data_length*8/data_rate*11+len;

info_plcp.state=state;
info_plcp.si=si;
info_plcp.len=len;
info_plcp.gap=gap;
info_plcp.pass=pass;
info_plcp.header=header;
info_plcp.service=service;
info_plcp.data_rate=data_rate;
info_plcp.data_length=data_length;
info_plcp.crc_16=crc_16;
info_plcp.mod_way=mod_way;
info_plcp.frame_index_end=frame_index_end;

end
function ht_sig = tx_gen_highthrough_sig(sim_options)
global sim_consts;
up=sim_options.upsample;
%% signal generation
mcs=dec2bin(sim_options.mcs,7);
for i=1:7
   signal(i)=str2double(mcs(8-i));
end
signal(8)=0;%cbw
ht_length=dec2bin(sim_options.PacketLength,16);
for i=9:24
   signal(i)=str2double(ht_length(25-i));
end
signal(25)=1;%smoothing
signal(26)=1;%not_sounding
signal(27)=1;%reserved
signal(28)=0;%aggregation
signal(30:-1:29)=[0 0];%stbc
signal(31)=0;%fec_code
signal(32)=0;%long_gi
signal(34:-1:33)=[0 0];%ness
signal(35:42)=crc_htsig(signal(1:34));
signal(48:-1:43)=zeros(6,1);
signal_rs=tx_conv_encoder(signal);
signal_lv=tx_interleaver(signal_rs,sim_consts.nonHTNumDataSubc,1);
signal_mod=tx_modulate(signal_lv,'BPSK').*1i;
signal52=tx_add_pilot_legacy_sig(signal_mod);
signal_time=tx_freqd_to_timed(signal52,up,sim_consts.nonHTNumSubc);
switch sim_options.Nss
    case(1)
        ht_sig(:,1)=tx_add_cyclic_prefix(signal_time,up);
    case(2)
        h_sig2=[signal_time(4*up+1:end,:);signal_time(1:4*up,:)];
        ht_sig(:,1)=tx_add_cyclic_prefix(signal_time,up);
        ht_sig(:,2)=tx_add_cyclic_prefix(h_sig2,up);
    case(3)
        h_sig2=[signal_time(2*up+1:end,:);signal_time(1:2*up,:)];
        h_sig3=[signal_time(4*up+1:end,:);signal_time(1:4*up,:)];
        ht_sig(:,1)=tx_add_cyclic_prefix(signal_time,up);  
        ht_sig(:,2)=tx_add_cyclic_prefix(h_sig2,up);
        ht_sig(:,3)=tx_add_cyclic_prefix(h_sig3,up);
    case(4)
        h_sig2=[signal_time(1*up+1:end,:);signal_time(1:1*up,:)];
        h_sig3=[signal_time(2*up+1:end,:);signal_time(1:2*up,:)];
        h_sig4=[signal_time(3*up+1:end,:);signal_time(1:3*up,:)];
        ht_sig(:,1)=tx_add_cyclic_prefix(signal_time,up);
        ht_sig(:,2)=tx_add_cyclic_prefix(h_sig2,up);
        ht_sig(:,3)=tx_add_cyclic_prefix(h_sig3,up);   
        ht_sig(:,4)=tx_add_cyclic_prefix(h_sig4,up); 
end
end
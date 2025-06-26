function l_sig = tx_gen_legacy_sig(sim_options)
global sim_consts;
up=sim_options.upsample;
sig_rate=[1,1,0,1];%6Mbps
if sim_options.Nss~=3
    txtime_tr=16+4+4+4*sim_options.Nss+8;
else
    txtime_tr=16+4+4+4*4+8;
end
txtime_data=ceil((sim_options.PacketLength*8+16+6)/sim_options.Ndbps)*4;
txtime=txtime_tr+txtime_data;
sig_length=ceil((txtime-20)/4)*3-3;
sig_length_bit=dec2bin(sig_length,12);
for i=1:12
	sig_len(i)=str2double(sig_length_bit(13-i));
end
signal_d=[sig_rate 0 sig_len];
for i=1:16
	signal_d(i+1)=xor(signal_d(i),signal_d(i+1));
end
signal=[sig_rate 0 sig_len signal_d(17) zeros(1,6)];
signal_rs=tx_conv_encoder(signal);
signal_lv=tx_interleaver(signal_rs,sim_consts.nonHTNumDataSubc,1);
signal_mod=tx_modulate(signal_lv,'BPSK');
signal52=tx_add_pilot_legacy_sig(signal_mod);
signal_time=tx_freqd_to_timed(signal52,up,sim_consts.nonHTNumSubc);
switch sim_options.Nss
    case(1)
        l_sig(:,1)=tx_add_cyclic_prefix(signal_time,up);
    case(2)
        l_sig2=[signal_time(4*up+1:end);signal_time(1:4*up)];
        l_sig(:,1)=tx_add_cyclic_prefix(signal_time,up);
        l_sig(:,2)=tx_add_cyclic_prefix(l_sig2,up);
    case(3)
        l_sig2=[signal_time(2*up+1:end);signal_time(1:2*up)];
        l_sig3=[signal_time(4*up+1:end);signal_time(1:4*up)];
        l_sig(:,1)=tx_add_cyclic_prefix(signal_time,up);  
        l_sig(:,2)=tx_add_cyclic_prefix(l_sig2,up);
        l_sig(:,3)=tx_add_cyclic_prefix(l_sig3,up);
    case(4)
        l_sig2=[signal_time(1*up+1:end);signal_time(1:1*up)];
        l_sig3=[signal_time(2*up+1:end);signal_time(1:2*up)];
        l_sig4=[signal_time(3*up+1:end);signal_time(1:3*up)];
        l_sig(:,1)=tx_add_cyclic_prefix(signal_time,up);
        l_sig(:,2)=tx_add_cyclic_prefix(l_sig2,up);
        l_sig(:,3)=tx_add_cyclic_prefix(l_sig3,up);   
        l_sig(:,4)=tx_add_cyclic_prefix(l_sig4,up); 
end
end
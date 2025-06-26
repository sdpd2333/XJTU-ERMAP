function l_sig=tx_gen_sig(sim_options)
switch sim_options.rate
    case{6}
        sig_rate=[1,1,0,1];
    case{9}
        sig_rate=[1,1,1,1];
    case{12}
        sig_rate=[0,1,0,1];
    case{18}
        sig_rate=[0,1,1,1];
    case{24}
        sig_rate=[1,0,0,1];
    case{36}
        sig_rate=[1,0,1,1];
    case{48}
        sig_rate=[0,0,0,1];
    case{54}
        sig_rate=[0,0,1,1];
end
sig_length_bit=dec2bin(sim_options.PacketLength,12);
for i=1:12
	sig_len(i)=str2double(sig_length_bit(13-i));
end
signal_d=[sig_rate 0 sig_len];
for i=1:16
	signal_d(i+1)=xor(signal_d(i),signal_d(i+1));
end
signal=[sig_rate 0 sig_len signal_d(17) zeros(1,6)];
signal_rs=tx_conv_encoder(signal);
signal_lv=tx_interleaver(signal_rs, 'BPSK');
signal_mod=tx_modulate(signal_lv,'BPSK');
signal52=tx_add_pilot_syms(signal_mod);
signal_time=tx_freqd_to_timed(signal52,sim_options.upsample);
l_sig=tx_add_cyclic_prefix(signal_time,sim_options.upsample);
function tx_11n = ieee802_11n_tx_func(in_byte,mcs,upsample)
sim_options.PacketLength=length(in_byte)+4;
sim_options.mcs=mcs;
if sim_options.mcs>=24
    sim_options.Nss=4;
elseif sim_options.mcs>=16
    sim_options.Nss=3;
elseif sim_options.mcs>=8
    sim_options.Nss=2;
else
    sim_options.Nss=1;
end
sim_options.upsample=upsample;
set_sim_options_lc;
%% generate non-HT training
l_stf = tx_gen_legacy_stf(sim_options);
l_ltf = tx_gen_legacy_ltf(sim_options);
%% generate non-HT signal
l_sig=tx_gen_legacy_sig(sim_options);
%% generate HT signal
ht_sig=tx_gen_highthrough_sig(sim_options);
%% generate HT training
ht_stf = tx_gen_highthrough_stf(sim_options);
ht_ltf = tx_gen_highthrough_ltf(sim_options);
%% HT data field
in_byte_col(:,1)=in_byte;
in_bits_1=de2bi(in_byte_col,8);
in_bits_r=in_bits_1(:,8:-1:1);
in_bits_re=in_bits_r.';
in_bits_s=in_bits_re(:);
in_bits(1,:)=in_bits_s;
ret=crc32(in_bits);
inf_bits=[in_bits ret.'];
data_bits=generate_data(inf_bits,sim_options);
scramble_bits=scramble_lc(data_bits,sim_options);
coded_bit=tx_conv_encoder(scramble_bits);
tx_bits = tx_puncture(coded_bit,sim_options);
tx_parser=tx_stream_parser(tx_bits,sim_options);
tx_inlv = tx_interleaver_ht(tx_parser,sim_options);
for i=1:sim_options.Nss
    tx_mod(:,i)=tx_modulate(tx_inlv(:,i),sim_options.Modulation);
end
up=sim_options.upsample;
tx_syms=tx_add_pilot_ht(tx_mod,sim_options);
for i=1:sim_options.Nss
    tx_time=tx_freqd_to_timed(tx_syms(:,i),up,sim_consts.HTNumSubc);
    switch i
        case(1)
            tx_csd=tx_time;
        case(2)
            tx_csd=[tx_time(8*up+1:end,:);tx_time(1:8*up,:)];
        case(3)
            tx_csd=[tx_time(4*up+1:end,:);tx_time(1:4*up,:)];
        case(4)
            tx_csd=[tx_time(12*up+1:end,:);tx_time(1:12*up,:)];
    end
    tx_data(:,i)=tx_add_cyclic_prefix(tx_csd,up);
end
tx_11n=[l_stf;l_ltf;l_sig;ht_sig;ht_stf;ht_ltf;tx_data];
%% psd
for i=1:size(tx_11n,2)
    subplot(1,size(tx_11n,2),i);
    pwelch(tx_11n(:,i),[],[],[],20e6*sim_options.upsample,'centered','psd');
end
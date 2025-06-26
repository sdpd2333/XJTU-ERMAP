function tx_11a = ieee802_11a_tx_func(in_byte,rate,upsample)
sim_consts = set_sim_consts_tx;
sim_options.PacketLength=length(in_byte)+4;
sim_options.rate=rate;
sim_options.upsample=upsample;
if sim_options.rate==6;
    sim_options.ConvCodeRate='R1/2';
    sim_options.Modulation='BPSK';
elseif sim_options.rate==9;
    sim_options.ConvCodeRate='R3/4';
    sim_options.Modulation='BPSK';
elseif  sim_options.rate==12;
    sim_options.ConvCodeRate='R1/2';
    sim_options.Modulation='QPSK';
elseif sim_options.rate==18;
    sim_options.ConvCodeRate='R3/4';
    sim_options.Modulation='QPSK';
elseif sim_options.rate==24;
    sim_options.ConvCodeRate='R1/2';
    sim_options.Modulation='16QAM';
elseif  sim_options.rate==36;
    sim_options.ConvCodeRate='R3/4';
    sim_options.Modulation='16QAM';
elseif  sim_options.rate==48;
    sim_options.ConvCodeRate='R2/3';
    sim_options.Modulation='64QAM';
elseif  sim_options.rate==54;
    sim_options.ConvCodeRate='R3/4';
    sim_options.Modulation='64QAM';
end
%% data generation
in_byte_col(:,1)=in_byte;
in_bits_1=de2bi(in_byte_col,8);
in_bits_r=in_bits_1(:,8:-1:1);
in_bits_re=in_bits_r.';
in_bits_s=in_bits_re(:);
in_bits(1,:)=in_bits_s;
ret=crc32(in_bits);
inf_bits=[in_bits ret.'];
service=zeros(1,16);
data_bits=tx_generate_data(inf_bits,service,sim_options);
%% scramble
scramble_int=[1,1,1,1,0,0,0];
scramble_bits=scramble_lc(scramble_int,data_bits,sim_options);
%% rs coding and punc
coded_bit_stream = tx_conv_encoder(scramble_bits); 
tx_bits = tx_puncture(coded_bit_stream, sim_options.ConvCodeRate);
rdy_to_mod_bits =tx_bits;
%% interleave
rdy_to_mod_bits = tx_interleaver(rdy_to_mod_bits,sim_options.Modulation);
%% Modulate
mod_syms = tx_modulate(rdy_to_mod_bits, sim_options.Modulation);
%% Add pilot symbols
mod_ofdm_syms = tx_add_pilot_syms(mod_syms);
%% Tx symbols to time domain
time_syms = tx_freqd_to_timed(mod_ofdm_syms,sim_options.upsample);
%% Add cyclic prefix
time_signal = tx_add_cyclic_prefix(time_syms,sim_options.upsample);
%% Construction of the preamble
preamble = tx_gen_preamble(sim_options);
%% signal generate
l_sig=tx_gen_sig(sim_options);
%% joint frame
tx_11a=[preamble l_sig time_signal].';
%% psd
pwelch(tx_11a,[],[],[],20e6*sim_options.upsample,'centered','psd');
%% fir
% flt1=rcosine(1,sim_options.upsample,'fir/sqrt',0.01,64);
% flt1=[38,18,-77,-102,39,67,-104,-93,152,81,-229,-56,317,-10,-414,120, ...
% 507,-291,-578,531,608,-856,-566,1285,414,-1867,-77,2727,-669,-4411,3364,16403, ...
% 16403,3364,-4411,-669,2727,-77,-1867,414,1285,-566,-856,608,531,-578,-291,507, ...
% 120,-414,-10,317,-56,-229,81,152,-93,-104,67,39,-102,-77,18,38];
% tx_11a=rcosflt(tx_11a,1,1, 'filter', flt1).';
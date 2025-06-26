%º¯Êıgenerate_data()
function data_bits=tx_generate_data(inf_bits,service,sim_options)
bits_ofdm_sym=sim_options.rate*4;
vaild_bits_length=16+length(inf_bits)+6;
pad_num=ceil(vaild_bits_length/bits_ofdm_sym).*bits_ofdm_sym-vaild_bits_length;
data_bits=[service inf_bits zeros(1,6) zeros(1,pad_num)];


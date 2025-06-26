function data_bits=generate_data(inf_bits,sim_options)
ndbps=sim_options.Ndbps;
length=sim_options.PacketLength;
num_symbol=ceil((8*length+16+6)/ndbps);
npad=num_symbol*ndbps-(8*length+16+6);
data_bits=[zeros(1,16),inf_bits,zeros(1,6),zeros(1,npad)];
end


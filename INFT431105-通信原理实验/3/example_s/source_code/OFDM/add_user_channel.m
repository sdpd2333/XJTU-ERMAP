function tx_11a=add_user_channel(tx_11a,phase_offset,noise,up)
%% add freq offset
rad_offset = 2*pi*phase_offset/1.4e6/up;
time_base=[0:length(tx_11a)-1].';
dds_offset=exp(-j*rad_offset*time_base);
tx_11a = tx_11a.*dds_offset;
%% add noise
tx_11a=awgn(tx_11a,noise,'measured'); 
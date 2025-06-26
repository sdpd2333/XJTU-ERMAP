function 802_11b_tx_func()
set_sim_options;
%% Create PLCP
plcp= tx_gen_plcp(sim_options);
%% Generate PSDU
psdu = tx_prbs15_lc(sim_options.length);
%% Combine PSDU with PLCP to PPDU
ppdu=[plcp psdu];
%% Scramble
if  sim_options.frame_type==1
    scramble_int=[1,1,0,1,1,0,0];
elseif sim_options.frame_type==0
    scramble_int=[0,0,1,1,0,1,1];
end
scramble_bits=scramble(scramble_int,ppdu);
%% Modulate Scrambled Data Based on Rate
tx_11b = tx_modulate(scramble_bits, sim_options);
%% psd
subplot(121);
pwelch(tx_11b,[],[],[],11e6,'centered','psd');
%% Raised cosine FIR filter
fir = rcosdesign(1,128,4);
tx_11b_44 = upfirdn(tx_11b,fir,4);
save('tx_11b_44.mat','tx_11b_44');
subplot(122);
pwelch(tx_11b_44,[],[],[],44e6,'centered','psd');
end
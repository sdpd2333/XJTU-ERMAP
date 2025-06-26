function correction_phases = rx_pilot_phase_est(freq_data_syms,rx_pilots)
global sim_consts;
num_symbols = size(freq_data_syms,2);
% Pilot scrambling pattern
scramble_patt = repmat(sim_consts.PilotScramble, sim_consts.NumPilotSubc,...
   ceil(num_symbols/length(sim_consts.PilotScramble)));
scramble_patt = scramble_patt(:,1:num_symbols);
ref_pilots = repmat(sim_consts.PilotSubcSymbols, 1, num_symbols);

% Estimate the symbol rotation from the pilot subcarriers
% Different Tx and/or Rx diversity options require different processing of the pilot symbols
   phase_error=sum(conj(ref_pilots).*squeeze(rx_pilots).*conj(scramble_patt));
   phase_error_est = angle(phase_error);
   correction_phases = zeros(sim_consts.NumSubc, num_symbols);
   correction_phases = repmat(phase_error_est, sim_consts.NumSubc, 1);   
end

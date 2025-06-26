function mod_ofdm_syms = tx_add_pilot_syms(mod_syms)

global sim_consts;

n_mod_syms = size(mod_syms,2);
n_ofdm_syms = n_mod_syms/sim_consts.NumDataSubc;

%pilot scrambling pattern
scramble_patt = repmat(sim_consts.PilotScramble,1,ceil(n_ofdm_syms/length(sim_consts.PilotScramble)));
% scramble_patt = scramble_patt(1:n_ofdm_syms).*2^10;
scramble_patt = scramble_patt(1:n_ofdm_syms);

mod_ofdm_syms = zeros(sim_consts.NumSubc, n_ofdm_syms);
mod_ofdm_syms(sim_consts.DataSubcPatt,:) = reshape(mod_syms, sim_consts.NumDataSubc, n_ofdm_syms);

mod_ofdm_syms(sim_consts.PilotSubcPatt,:) = repmat(scramble_patt, sim_consts.NumPilotSubc,1).* ...
   repmat(sim_consts.PilotSubcSymbols, 1, n_ofdm_syms);

mod_ofdm_syms = mod_ofdm_syms(:).';


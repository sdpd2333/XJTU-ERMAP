function mod_ofdm_syms = tx_add_pilot_legacy_sig(mod_syms)
global sim_consts;
num_symbols=length(mod_syms)/sim_consts.nonHTNumDataSubc;
mod_grp = reshape(mod_syms,sim_consts.nonHTNumDataSubc,num_symbols);
%pilot scrambling pattern
pilot=repmat([1;1;1;-1],1,num_symbols);
mod_ofdm_syms=zeros(sim_consts.nonHTNumSubc,num_symbols);
mod_ofdm_syms(sim_consts.nonHTDataSubcPatt,:) = mod_grp;
mod_ofdm_syms(sim_consts.nonHTPilotSubcPatt,:) = pilot;
mod_ofdm_syms=mod_ofdm_syms(:);
end


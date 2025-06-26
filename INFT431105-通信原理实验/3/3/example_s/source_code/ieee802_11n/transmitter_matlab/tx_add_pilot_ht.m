function tx_syms = tx_add_pilot_ht(tx_mod,sim_options)
global sim_consts;
nss=sim_options.Nss;
for i=1:nss
    num_symbols=length(tx_mod(:,i))/sim_consts.HTNumDataSubc;
    mod_grp = reshape(tx_mod(:,i),sim_consts.HTNumDataSubc,num_symbols);
    scramble_patt=repmat(sim_consts.PilotScramble,1,ceil(num_symbols/length(sim_consts.PilotScramble)));
    scr_patt=repmat(scramble_patt(1:num_symbols),4,1);
    %pilot scrambling pattern
    pilot_base=sim_consts.pilot((nss-1)*4+i,:).';
    pilot(:,1)=pilot_base;
    for j=2:num_symbols
        pilot(:,j)=pilot([2,3,4,1],j-1);
    end
    pilot=pilot.*scr_patt;
    tx_syms_grp(sim_consts.HTDataSubcPatt,:)=mod_grp;
    tx_syms_grp(sim_consts.HTPilotSubcPatt,:)=pilot;
    tx_syms(:,i)=tx_syms_grp(:);
end


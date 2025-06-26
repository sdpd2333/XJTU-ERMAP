function short_trs = tx_gen_legacy_stf(sim_options)
global sim_consts;
%Generate first ten short training symbols
up=sim_options.upsample;
short_tr = sim_consts.legacyshorttraning;
short_tr_symbols = tx_freqd_to_timed(short_tr,up,sim_consts.nonHTNumSubc);
% Pick one short training symbol
Strs = short_tr_symbols(1:16*up);
switch sim_options.Nss
    case(1)
        short_trs(:,1)=repmat(Strs,10,1);
    case(2)
        short_trs(:,1)=repmat(Strs,10,1);
        short_trs(:,2)=[Strs(4*up+1:end);repmat(Strs,9,1);Strs(1:4*up)];
    case(3)
        short_trs(:,1)=repmat(Strs,10,1);
        short_trs(:,2)=[Strs(2*up+1:end);repmat(Strs,9,1);Strs(1:2*up)];
        short_trs(:,3)=[Strs(4*up+1:end);repmat(Strs,9,1);Strs(1:4*up)];
    case(4)
        short_trs(:,1)=repmat(Strs,10,1);
        short_trs(:,2)=[Strs(1*up+1:end);repmat(Strs,9,1);Strs(1:1*up)];
        short_trs(:,3)=[Strs(2*up+1:end);repmat(Strs,9,1);Strs(1:2*up)];
        short_trs(:,4)=[Strs(3*up+1:end);repmat(Strs,9,1);Strs(1:3*up)];
end
end

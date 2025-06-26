function long_trs = tx_gen_legacy_ltf(sim_options)
global sim_consts;
%Generate first two long training symbols
up=sim_options.upsample;
long_tr = sim_consts.legacylongtraning;
long_tr_symbols = tx_freqd_to_timed(long_tr,up,sim_consts.nonHTNumSubc);
ltrs = long_tr_symbols;
switch sim_options.Nss
    case(1)
        long_trs(:,1)=[ltrs(end/2+1:end);repmat(ltrs,2,1)];
    case(2)
        long2=[ltrs(4*up+1:end);ltrs(1:4*up)];
        long_trs(:,1)=[ltrs(end/2+1:end);repmat(ltrs,2,1)];
        long_trs(:,2)=[long2(end/2+1:end);long2;long2];
    case(3)
        long2=[ltrs(2*up+1:end);ltrs(1:2*up)];
        long3=[ltrs(4*up+1:end);ltrs(1:4*up)];
        long_trs(:,1)=[ltrs(end/2+1:end);repmat(ltrs,2,1)];    
        long_trs(:,2)=[long2(end/2+1:end);long2;long2];
        long_trs(:,3)=[long3(end/2+1:end);long3;long3];
    case(4)
        long2=[ltrs(1*up+1:end);ltrs(1:1*up)];
        long3=[ltrs(2*up+1:end);ltrs(1:2*up)];
        long4=[ltrs(3*up+1:end);ltrs(1:3*up)];
        long_trs(:,1)=[ltrs(end/2+1:end);repmat(ltrs,2,1)];
        long_trs(:,2)=[long2(end/2+1:end);long2;long2];  
        long_trs(:,3)=[long3(end/2+1:end);long3;long3];    
        long_trs(:,4)=[long4(end/2+1:end);long4;long4];
end
end

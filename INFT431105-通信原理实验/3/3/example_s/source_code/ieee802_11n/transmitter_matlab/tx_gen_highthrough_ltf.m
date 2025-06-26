function long_trs = tx_gen_highthrough_ltf(sim_options)
global sim_consts;
up=sim_options.upsample;
long_tr = sim_consts.highthroughlongtraning;
ltr_time = tx_freqd_to_timed(long_tr,up,sim_consts.HTNumSubc);
% Pick one short training symbol
switch sim_options.Nss
    case(1)
        long_trs(:,1)=tx_add_cyclic_prefix(ltr_time,up);
    case(2)
        ltr11=tx_add_cyclic_prefix(ltr_time,up);
        long_trs(:,1)=[ltr11;ltr11.*(-1)];
        ltr2=[ltr_time(8*up+1:end);ltr_time(1:8*up)];
        ltr22=tx_add_cyclic_prefix(ltr2,up);
        long_trs(:,2)=[ltr22;ltr22];
    case(3)
        ltr11=tx_add_cyclic_prefix(ltr_time,up);
        long_trs(:,1)=[ltr11;ltr11.*(-1);ltr11;ltr11];
        ltr2=[ltr_time(8*up+1:end);ltr_time(1:8*up)];
        ltr22=tx_add_cyclic_prefix(ltr2,up);
        long_trs(:,2)=[ltr22;ltr22;ltr22.*(-1);ltr22];
        ltr3=[ltr_time(4*up+1:end);ltr_time(1:4*up)];
        ltr33=tx_add_cyclic_prefix(ltr3,up);
        long_trs(:,3)=[ltr33;ltr33;ltr33;ltr33.*(-1)];
    case(4)
        ltr11=tx_add_cyclic_prefix(ltr_time,up);
        long_trs(:,1)=[ltr11;ltr11.*(-1);ltr11;ltr11];
        ltr2=[ltr_time(8*up+1:end);ltr_time(1:8*up)];
        ltr22=tx_add_cyclic_prefix(ltr2,up);
        long_trs(:,2)=[ltr22;ltr22;ltr22.*(-1);ltr22];
        ltr3=[ltr_time(4*up+1:end);ltr_time(1:4*up)];
        ltr33=tx_add_cyclic_prefix(ltr3,up);
        long_trs(:,3)=[ltr33;ltr33;ltr33;ltr33.*(-1)];
        ltr4=[ltr_time(12*up+1:end);ltr_time(1:12*up)];
        ltr44=tx_add_cyclic_prefix(ltr4,up);
        long_trs(:,4)=[ltr44.*(-1);ltr44;ltr44;ltr44];
end
end

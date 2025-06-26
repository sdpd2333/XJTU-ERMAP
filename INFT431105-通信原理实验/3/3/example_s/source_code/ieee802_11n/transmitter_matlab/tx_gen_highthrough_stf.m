function short_trs = tx_gen_highthrough_stf(sim_options)
global sim_consts;
up=sim_options.upsample;
short_tr = sim_consts.legacyshorttraning;
str_time = tx_freqd_to_timed(short_tr,up,sim_consts.nonHTNumSubc);
% Pick one short training symbol
switch sim_options.Nss
    case(1)
        short_trs(:,1)=tx_add_cyclic_prefix(str_time,up);
    case(2)
        str2=[str_time(8*up+1:end);str_time(1:8*up)];
        short_trs(:,1)=tx_add_cyclic_prefix(str_time,up);
        short_trs(:,2)=tx_add_cyclic_prefix(str2,up);
    case(3)
        str2=[str_time(8*up+1:end);str_time(1:8*up)];
        str3=[str_time(4*up+1:end);str_time(1:4*up)];
        short_trs(:,1)=tx_add_cyclic_prefix(str_time,up);  
        short_trs(:,2)=tx_add_cyclic_prefix(str2,up);
        short_trs(:,3)=tx_add_cyclic_prefix(str3,up);
    case(4)
        str2=[str_time(8*up+1:end);str_time(1:8*up)];
        str3=[str_time(4*up+1:end);str_time(1:4*up)];
        str4=[str_time(12*up+1:end);str_time(1:12*up)];
        short_trs(:,1)=tx_add_cyclic_prefix(str_time,up);
        short_trs(:,2)=tx_add_cyclic_prefix(str2,up);
        short_trs(:,3)=tx_add_cyclic_prefix(str3,up);   
        short_trs(:,4)=tx_add_cyclic_prefix(str4,up); 
end
end

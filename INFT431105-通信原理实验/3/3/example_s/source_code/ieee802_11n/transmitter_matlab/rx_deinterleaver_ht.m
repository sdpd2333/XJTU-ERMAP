function delv_bits=rx_deinterleaver_ht(in_bits,sim_options)
global sim_consts;
nss=sim_options.Nss;
nbpscs=sim_options.Nbpscs;
inlv_depth=nbpscs*sim_consts.HTNumDataSubc;
num_symbols=length(in_bits(:,1))/inlv_depth;
% Get interleaver pattern for symbols
nrow=4*nbpscs;
ncol=13;
nrot=11;
s=max(1,nbpscs/2);
for iss=1:nss
    for r=0:inlv_depth-1
    indexj=mod((r+(rem((iss-1)*2,3)+3*floor((iss-1)/3))*nrot*nbpscs),inlv_depth);
    indexi=s*floor(indexj/s)+rem((indexj+floor(ncol*indexj/inlv_depth)),s);
    indexk(r+1,iss)=ncol*indexi-(inlv_depth-1)*floor(indexi/nrow);
    end 
end
intlvr_patt=indexk+1;
% Generate intereleaver pattern for the whole packet
for i=1:nss
    in_bits_grp=reshape(in_bits(:,i),inlv_depth,num_symbols);
    for j=1:num_symbols
        inlv_bits_grp(intlvr_patt(:,i),j)=in_bits_grp(:,j);
    end
    delv_bits(:,i)=inlv_bits_grp(:);
end
end

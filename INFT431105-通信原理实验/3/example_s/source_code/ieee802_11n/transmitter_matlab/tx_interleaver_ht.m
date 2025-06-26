function inlv_bits=tx_interleaver_ht(in_bits,sim_options)
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
for k=0:inlv_depth-1
    indexi=nrow*rem(k,ncol)+floor(k/ncol);
    indexj=s*floor(indexi/s)+rem((indexi+inlv_depth-floor(ncol*indexi/inlv_depth)),s);
    for iss=1:nss
        indexr(k+1,iss)=mod((indexj-(rem((iss-1)*2,3)+3*floor((iss-1)/3))*nrot*nbpscs),inlv_depth);
    end 
end
intlvr_patt=indexr+1;
% Generate intereleaver pattern for the whole packet
for i=1:nss
    in_bits_grp=reshape(in_bits(:,i),inlv_depth,num_symbols);
    for j=1:num_symbols
        inlv_bits_grp(intlvr_patt(:,i),j)=in_bits_grp(:,j);
    end
    inlv_bits(:,i)=inlv_bits_grp(:);
end
end

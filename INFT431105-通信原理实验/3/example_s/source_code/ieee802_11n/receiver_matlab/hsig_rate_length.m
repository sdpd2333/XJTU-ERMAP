function [sim_options,error]=hsig_rate_length(signal)
sim_options.mcs=bin2dec(num2str(signal(7:-1:1)));
crc_calc=crc_htsig(signal(1:34));
crc_outputs=sum(xor(signal(35:42).',crc_calc));
if crc_outputs==0
    error=0;
else
    error=1;
end
sim_options.PacketLength=bin2dec(num2str(signal(24:-1:9)));
if sim_options.mcs<=7
    sim_options.Nss=1;
elseif sim_options.mcs<=15
    sim_options.Nss=2;
elseif sim_options.mcs<=22
    sim_options.Nss=3;
else
    sim_options.Nss=4;
end
switch sim_options.mcs
    case{0,8,16,24}
        sim_options.Modulation='BPSK';
        sim_options.ConvCodeRate=1/2;
        sim_options.Nbpscs=1;
        sim_options.Ncbps=52*sim_options.Nss;
        sim_options.Ndbps=26*sim_options.Nss;
    case{1,9,17,25}
        sim_options.Modulation='QPSK';
        sim_options.ConvCodeRate=1/2;
        sim_options.Nbpscs=2;
        sim_options.Ncbps=104*sim_options.Nss;
        sim_options.Ndbps=52*sim_options.Nss;
    case{2,10,18,26}
        sim_options.Modulation='QPSK';
        sim_options.ConvCodeRate=3/4;
        sim_options.Nbpscs=2;
        sim_options.Ncbps=104*sim_options.Nss;
        sim_options.Ndbps=78*sim_options.Nss;        
    case{3,11,19,27}
        sim_options.Modulation='16QAM';
        sim_options.ConvCodeRate=1/2;
        sim_options.Nbpscs=4;
        sim_options.Ncbps=208*sim_options.Nss;
        sim_options.Ndbps=104*sim_options.Nss; 
    case{4,12,20,28}
        sim_options.Modulation='16QAM';
        sim_options.ConvCodeRate=3/4;
        sim_options.Nbpscs=4;
        sim_options.Ncbps=208*sim_options.Nss;
        sim_options.Ndbps=156*sim_options.Nss; 
    case{5,13,21,29}
        sim_options.Modulation='64QAM';
        sim_options.ConvCodeRate=2/3;
        sim_options.Nbpscs=6;
        sim_options.Ncbps=312*sim_options.Nss;
        sim_options.Ndbps=208*sim_options.Nss; 
    case{6,14,22,30}
        sim_options.Modulation='64QAM';
        sim_options.ConvCodeRate=3/4;
        sim_options.Nbpscs=6;
        sim_options.Ncbps=312*sim_options.Nss;
        sim_options.Ndbps=234*sim_options.Nss; 
     case{7,15,23,31}
        sim_options.Modulation='64QAM';
        sim_options.ConvCodeRate=5/6;
        sim_options.Nbpscs=6;
        sim_options.Ncbps=312*sim_options.Nss;
        sim_options.Ndbps=260*sim_options.Nss; 
    otherwise
        error=1;
end
if error==1
    sim_options.Nsym=0;
else
    sim_options.Nsym=ceil((8*sim_options.PacketLength+16+6)/sim_options.Ndbps);
end

    
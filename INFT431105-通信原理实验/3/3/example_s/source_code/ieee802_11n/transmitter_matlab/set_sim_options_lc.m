sim_consts = set_sim_consts;
%% MCS define
% Nbpsc=Number of coded bits per symbol per the i-th spatial stream
% Ncbps=Number of coded bits per symbol
% Ndbps=Number of data bits per symbol
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
end
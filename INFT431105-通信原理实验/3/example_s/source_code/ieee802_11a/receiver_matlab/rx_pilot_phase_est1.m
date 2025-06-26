function [correction_phases,k] = rx_pilot_phase_est1(freq_data_syms,rx_pilots)
global sim_consts;
num_symbols = size(freq_data_syms,2);
% Pilot scrambling pattern
scramble_patt = repmat(sim_consts.PilotScramble, sim_consts.NumPilotSubc,...
   ceil(num_symbols/length(sim_consts.PilotScramble)));
scramble_patt = scramble_patt(:,1:num_symbols);
ref_pilots = repmat(sim_consts.PilotSubcSymbols, 1, num_symbols);
phase=angle(ref_pilots.*rx_pilots.*scramble_patt);
x2=[-3;-1;1;3];
for i=1:size(phase,2)
    ang=phase(:,i);
    for j=1:4
        delta = ang(j) - ang(1);
        if delta > pi
            ang(j) = ang(j) - 2*pi;
        elseif delta < -pi
            ang(j) = ang(j) + 2*pi;
        end
    end
%     k(i)=sum((ang.*x2))/20/7;
%     correction_phases(:,i)=mean(ang)+[(-26:-1) (1:26)]*k(i);
    k(i)=sum((ang.*x2))*(1/128-1/2048-1/4096);
    correction_phases(:,i)=mean(ang)+[(-26:-1) (1:26)]*k(i);
end  
end

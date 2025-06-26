function [signal_out,phase_error_degree] = rx_pilot_phase(rx_signal)
global sim_consts;
Nsym=size(rx_signal,1)./sim_consts.HTNumSubc;
Nrx=size(rx_signal,2);
for i=1:Nrx
    rx_signal_sym=reshape(rx_signal(:,i),sim_consts.HTNumSubc,Nsym);
    rx_pilot_sym=rx_signal_sym(sim_consts.HTPilotSubcPatt,:);
    rx_data_sym=rx_signal_sym(sim_consts.HTDataSubcPatt,:);
    scramble_patt=repmat(sim_consts.PilotScramble,1,ceil(Nsym/length(sim_consts.PilotScramble)));
    scr_patt=repmat(scramble_patt(1:Nsym),4,1);
    pilot_base=sim_consts.pilot((Nrx-1)*4+i,:).';
    pilot(:,1)=pilot_base;
    for j=2:Nsym
        pilot(:,j)=pilot([2,3,4,1],j-1);
    end
    ref_pilots=pilot.*scr_patt;
    phase_error=sum(conj(ref_pilots).*rx_pilot_sym);
    phase_error_est=angle(phase_error);
    phase_error_degree(:,i)=phase_error_est./pi.*180;
    correction_phases=repmat(phase_error_est,sim_consts.HTNumDataSubc,1);  
    signal_cor=rx_data_sym.*(cos(correction_phases)-1i*sin(correction_phases));
    signal_out(:,i)=signal_cor(:);
end

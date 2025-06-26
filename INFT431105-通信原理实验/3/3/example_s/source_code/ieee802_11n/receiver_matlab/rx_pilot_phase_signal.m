function signal_out = rx_pilot_phase_signal(rx_signal)
global sim_consts;
num_symbols=size(rx_signal,1)./52;
rx_signal_sym=reshape(rx_signal,52,num_symbols);
rx_pilot_sym=rx_signal_sym(sim_consts.nonHTPilotSubcPatt,:);
rx_data_sym=rx_signal_sym(sim_consts.nonHTDataSubcPatt,:);
% local pilot
ref_pilots=repmat([1;1;1;-1],1,num_symbols);
phase_error=sum(conj(ref_pilots).*rx_pilot_sym);
phase_error_est=angle(phase_error);
correction_phases=repmat(phase_error_est,48,1);  
signal_cor=rx_data_sym.*(cos(correction_phases)-1i*sin(correction_phases));
signal_out=signal_cor(:);
end

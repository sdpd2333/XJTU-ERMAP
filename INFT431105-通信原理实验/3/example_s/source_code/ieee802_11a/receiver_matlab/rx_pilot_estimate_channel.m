function channel_est = rx_pilot_estimate_channel(rx_freq_data)
global sim_consts;
freq_data=rx_freq_data(sim_consts.DataSubcPatt,:);
pilot_data=rx_freq_data(sim_consts.PilotSubcPatt,:);
num_symbols = size(freq_data,2);
% Pilot scrambling pattern
scramble_patt = repmat(sim_consts.PilotScramble, sim_consts.NumPilotSubc,...
   ceil(num_symbols/length(sim_consts.PilotScramble)));
scramble_patt = scramble_patt(:,1:num_symbols);
ref_pilots = repmat(sim_consts.PilotSubcSymbols, 1, num_symbols);

% Estimate the symbol rotation from the pilot subcarriers
% Different Tx and/or Rx diversity options require different processing of the pilot symbols
   symbol_estimation=conj(ref_pilots).*squeeze(pilot_data).*conj(scramble_patt);
%    channel_est(1:52,:)=interp1(sim_consts.PilotSubcPatt,symbol_estimation,[1:52],'cubic');
   channel_est(1:5,:)=repmat(symbol_estimation(1,:),5,1);
   channel_est(48:52,:)=repmat(symbol_estimation(4,:),5,1);
   channel_est(6:47,:)=interp1(sim_consts.PilotSubcPatt,symbol_estimation,[6:47],'linear');
%    channel_est(1:13,:)=repmat(symbol_estimation(1,:),13,1);
%    channel_est(14:26,:)=repmat(symbol_estimation(2,:),13,1);
%    channel_est(27:39,:)=repmat(symbol_estimation(3,:),13,1);
%    channel_est(40:52,:)=repmat(symbol_estimation(4,:),13,1);
   figure(2);
   for i=1:round(size(channel_est,2)/10)
       plot(abs(channel_est(:,i)));hold on;
   end
   set(gcf,'name','导频信道估计');
   figure(1);
end

%

function channel_estimate = rx_estimate_channel(freq_tr_syms)
   global sim_consts;
   % Estimate from training symbols
%    LongTrainingSymbols=[0 0 0 0 0 0 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 0 ...
%       1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1 0 0 0 0 0];

   mean_symbols = mean(freq_tr_syms.');
   channel_estimate = mean_symbols.*conj(sim_consts.LongTrainingSymbols);
   channel_estimate=channel_estimate.';

end

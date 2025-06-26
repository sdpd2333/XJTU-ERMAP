
function preamble = tx_gen_preamble(sim_options);
global sim_consts;
%Generate first ten short training symbols
up=sim_options.upsample;
short_tr = sim_consts.ShortTrainingSymbols;
% generate four short training symbols
short_tr_symbols = tx_freqd_to_timed(short_tr,up);
% Pick one short training symbol
Strs = short_tr_symbols(1:16*up);
% extend to ten short training symbols
short_trs=[Strs Strs Strs Strs Strs Strs Strs Strs Strs Strs];
short_trs_len=length(short_trs);
% next generate the two long training symbols
long_tr = sim_consts.LongTrainingSymbols;
long_tr_symbol = tx_freqd_to_timed(long_tr,up);

% extend with the 2*guard interval in front and then two long training symbols 
long_trs_signal = [long_tr_symbol(end/2+1:end) long_tr_symbol long_tr_symbol];

% concatenate first short training symbols and long training symbols
preamble = [short_trs long_trs_signal];

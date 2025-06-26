function punctured_bits=tx_puncture(in_bits,sim_options)
code_rate=sim_options.ConvCodeRate;
[punc_patt,punc_patt_size]=get_punc_params(code_rate);
puncture_table=reshape(in_bits,punc_patt_size,length(in_bits)/punc_patt_size);
tx_table=puncture_table(punc_patt,:);
punctured_bits=tx_table(:);
end


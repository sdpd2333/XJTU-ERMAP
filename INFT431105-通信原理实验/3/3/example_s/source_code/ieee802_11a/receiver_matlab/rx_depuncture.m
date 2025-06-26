function [depunctured_bits,erase_pattern] = rx_depuncture(in_bits, code_rate)

[punc_patt, punc_patt_size] = get_punc_params(code_rate);
depuncture_table = zeros(punc_patt_size, (length(in_bits)/length(punc_patt)));
depunc_bits = reshape(in_bits,length(punc_patt),(length(in_bits)/length(punc_patt)));
depuncture_table(punc_patt,:) = depunc_bits;
depunctured_bits = [depuncture_table(:)'];

erase_table=ones(punc_patt_size, (length(in_bits)/length(punc_patt)));
erase_bits=zeros(length(punc_patt),(length(in_bits)/length(punc_patt)));
erase_table(punc_patt,:) = erase_bits;
erase_pattern = [erase_table(:)'];
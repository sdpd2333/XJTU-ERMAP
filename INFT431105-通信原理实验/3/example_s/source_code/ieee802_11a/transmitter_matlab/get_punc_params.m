function [punc_patt, punc_patt_size] = get_punc_params(code_rate)

if strcmp(code_rate,'R3/4')
   % R=3/4, Puncture pattern: [1 2 3 x x 6], x = punctured 
   punc_patt=[1 2 3 6];
   punc_patt_size = 6;
elseif strcmp(code_rate, 'R2/3')
   % R=2/3, Puncture pattern: [1 2 3 x], x = punctured 
   punc_patt=[1 2 3]; 
   punc_patt_size = 4;
elseif strcmp(code_rate, 'R1/2')
   % R=1/2, Puncture pattern: [1 2 3 4 5 6], x = punctured 
   punc_patt=[1 2 3 4 5 6];
   punc_patt_size = 6;
else
   error('Undefined convolutional code rate');
end

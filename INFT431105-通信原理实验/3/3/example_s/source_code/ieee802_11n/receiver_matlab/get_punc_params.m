function [punc_patt,punc_patt_size]=get_punc_params(code_rate)
switch code_rate
    case(5/6)%[1 2 3 x x 6 7 x x 10], x = punctured
        punc_patt=[1 2 3 6 7 10];
        punc_patt_size=10;
    case(3/4)%[1 2 3 x x 6], x = punctured 
        punc_patt=[1 2 3 6];
        punc_patt_size=6;
    case(2/3)%[1 2 3 x], x = punctured 
        punc_patt=[1 2 3]; 
        punc_patt_size=4;
    case(1/2)%[1 2 3 4 5 6 7 8 9 10 11 12 13], x = punctured     
        punc_patt=[1 2 3 4 5 6 7 8 9 10 11 12 13];
        punc_patt_size=13;
end
end

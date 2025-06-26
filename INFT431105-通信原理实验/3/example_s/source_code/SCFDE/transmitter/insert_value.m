%x是待插值的序列，ratio是插值的比例。
function y=insert_value(x,ratio)
%两路信号进行插值
y=zeros(1,ratio*length(x));
a=1:ratio:length(y);
y(a)=x;
end

%x�Ǵ���ֵ�����У�ratio�ǲ�ֵ�ı�����
function y=insert_value(x,ratio)
%��·�źŽ��в�ֵ
y=zeros(1,ratio*length(x));
a=1:ratio:length(y);
y(a)=x;
end

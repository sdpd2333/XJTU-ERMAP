function [y1,y2]=pick_sig(x1,x2,ratio)
y1=x1(ratio*3*2+1:ratio:(length(x1)-ratio*3*2));
y2=x2(ratio*3*2+1:ratio:(length(x1)-ratio*3*2));

end
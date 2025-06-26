function [spreadData]=dsss(ppdu,inputcode)
data=[];
PN_length=length(inputcode);
dataLength=length(ppdu);
spreadData = zeros(1, dataLength*PN_length);
temp = ones(1, PN_length);

for i = 1:dataLength
    temp = ones(1, PN_length)*ppdu(i);
    % dsss
    spreadData(((i-1)*PN_length+1):i*PN_length) = temp.*inputcode;
end
end


function out_bits=jiema74(bit_s)
n=length(bit_s);
h=[1 0 1 0 1 0 1;0 1 1 0 0 1 1;0 0 0 1 1 1 1];
bit_s=bit_s(1:2044);
a=0;
bit_h=reshape(bit_s,7,2044/7);
bit_h=bit_h';
for i=1:floor(n/7)
    s(i,:)=bit_h(i,:)*h';
    for j=1:3
        s(i,j)=mod(s(i,j),2);
    end
    t=s(i,:)*[1;2;4];
    if t==0
    
       bits(i,1)=bit_h(i,3);
       bits(i,2)=bit_h(i,5);
       bits(i,3)=bit_h(i,6);
       bits(i,4)=bit_h(i,7);
    else
       a=a+1;
       bit_h(i,t)=1-bit_h(i,t);
       bits(i,1)=bit_h(i,3);
       bits(i,2)=bit_h(i,5);
       bits(i,3)=bit_h(i,6);
       bits(i,4)=bit_h(i,7);
    end
end
fprintf('误码率为：%f\n',a/floor(n/7))

bits=reshape(bits',4*floor(n/7),1);
out_bits=bits';
out_bits=[out_bits zeros(1,880)];

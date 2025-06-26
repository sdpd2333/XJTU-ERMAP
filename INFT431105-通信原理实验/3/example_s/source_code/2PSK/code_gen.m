%%²úÉú1023¸öÎ±Âë
function [code]=code_gen(code_phase);
G1=[1 1 1 1 1 1 1 1 1 1];
G2=[1 1 1 1 1 1 1 1 1 1];
for m=1:1023
      X(m)=mod(G1(10)+G2(code_phase(1))+G2(code_phase(2)),2);
      TEMP1=mod(G1(3)+G1(10),2);
      TEMP2=mod(G2(2)+G2(3)+G2(6)+G2(8)+G2(9)+G2(10),2);
      for n=10:-1:2
          G1(n)=G1(n-1);
          G2(n)=G2(n-1);
      end
      G1(1)=TEMP1;
      G2(1)=TEMP2;
     
end
index=find(X==0);
X(index)=-1;
code=X;



          
      
      
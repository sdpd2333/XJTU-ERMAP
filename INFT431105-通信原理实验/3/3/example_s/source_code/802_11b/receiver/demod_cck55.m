function dout = demod_cck55(signal)

%*********************CCK5.5解调数据**********************%

e = 0;
f = 0;
Tword = [ j  1  j -1  j  1 -j  1;
         -j -1 -j  1  j  1 -j  1;
         -j  1 -j -1 -j  1  j  1;
          j -1  j  1 -j  1  j  1];
sign = 0;%符号初始编号为0

Rx_code=signal;

for m=1:8:length(Rx_code)   
    % FWT （fast walsh transform）迭代算法    
    temp=Rx_code(m:(m+7)); %每次FWT处理8bits 
    for n = 1:4
        R(n) = sum(temp.*conj(Tword(n,:)));%注意一定要对C取共轭
    end
    
    V = abs(R); 
   [value col]=max(V); % 寻找4个相关值的最大值及其位置
   
   dtemp = zeros(1,4); 
   if(col == 1) 
       dtemp(3) = 0;
       dtemp(4) = 0;
   elseif(col == 2) 
       dtemp(3) = 0;
       dtemp(4) = 1;
   elseif(col == 3) 
       dtemp(3) = 1;
       dtemp(4) = 0;
   else
       dtemp(3) = 1;
       dtemp(4) = 1;
   end
   
    
   %根据最大峰值的相位判决出第一个相位值thet1
   a = real(R(col));
   b = imag(R(col));
   if (a<=0)&(b<=0) %每个判决值有个范围
       en = 0;
       fn = 0;
   elseif (a<=0)&(b>0)
       en = 1;
       fn = 0;
   elseif (a>0)&(b<=0)
       en = 0;
       fn = 1;
   else
       en = 1;
       fn = 1;
   end
   
   if(mod(sign,2) == 1)
       en = ~en;
       fn = ~fn;
   end
   
   sign = sign + 1;
  
    
   %码反变换
   if(e==f)
         dtemp(1) = xor(en,e);
         dtemp(2) = xor(fn,f);
   else
         dtemp(1) = xor(fn,f);
         dtemp(2) = xor(en,e);
   end   
   e = en;
   f = fn;
   
   dout((m+1)/2+(0:3)) = dtemp;%.*fact; %每次FWT处理8bits

end


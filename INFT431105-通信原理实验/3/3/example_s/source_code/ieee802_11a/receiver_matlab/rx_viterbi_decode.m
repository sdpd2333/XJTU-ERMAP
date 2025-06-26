function out_bits = rx_viterbi_decode(rx_bits,code_rate)
b=zeros(6,64);
%该算法之前先在C上编写过，这里只是翻译过来而已
    for i=1:6
        for j=1:64
         b(i,j)=0;
        end
    end
    for i=1:length(rx_bits)/2
        for j=1:64
            v(i,j,1)=65;
            v(i,j,2)=65536;
        end
    end
    v(1,1,2)=0;
    b(1,1)=1;
    for i=1:6
        if code_rate=='R1/2'
            	c1=1;c2=1;
        end
        if code_rate=='R2/3'
            		c1=1;	
				if mod((i-1),2)==1
					c2=0;
				else 
					c2=1;
                end
        end
        if code_rate=='R3/4'
            if mod((i-1),3)==2 
				c1=0;
			else 
				c1=1;
            end
			if mod((i-1),3)==1
				c2=0;
			else 
				c2=1;
            end
        end
        for j=1:64
				if b(i,j)==1
                    v((i+1),(floor((j-1)/2)+1),1)=j;b((i+1),(floor((j-1)/2)+1))=1;
					gg1=mod((0+floor((mod((j-1),32))/16)+floor((mod((j-1),16))/8)+floor((mod((j-1),4))/2)+mod((j-1),2)),2); %计算gg1，gg2；gg1，gg2是各个状态之间转移时的输出
                    gg2=mod((0+floor((j-1)/32)+floor((mod((j-1),32))/16)+floor((mod((j-1),16))/8)+mod((j-1),2)),2);
                    v((i+1),(floor((j-1)/2)+1),2)=v(i,j,2)+c1*mod((gg1+rx_bits(1,2*(i-1)+1)),2)+c2*mod((gg2+rx_bits(1,2*(i-1)+2)),2);%更新累积的汉明距离
                    
                    v((i+1),(floor((j-1)/2)+1+32),1)=j;b((i+1),(floor((j-1)/2)+1+32))=1;
                    gg1=mod((1+floor((mod((j-1),32))/16)+floor((mod((j-1),16))/8)+floor((mod((j-1),4))/2)+mod((j-1),2)),2); %计算gg1，gg2；gg1，gg2是各个状态之间转移时的输出
                    gg2=mod((1+floor((j-1)/32)+floor((mod((j-1),32))/16)+floor((mod((j-1),16))/8)+mod((j-1),2)),2);
                    
                    v((i+1),(floor((j-1)/2)+1+32),2)=v(i,j,2)+c1*mod((gg1+rx_bits(1,2*(i-1)+1)),2)+c2*mod((gg2+rx_bits(1,2*(i-1)+2)),2);%更新累积的汉明距离
                end
        end
    end
  
    for i=8:(length(rx_bits)/2+1)
        if code_rate=='R1/2'
            	c1=1;c2=1;
        end
        if code_rate=='R2/3'
            		c1=1;
				if mod((i-1),2)==0
					c2=0;
				else 
					c2=1;
                end
        end
        if code_rate=='R3/4'
            if mod((i-1),3)==0 
				c1=0;
			else 
				c1=1;
            end
			if mod((i-1),3)==2
				c2=0;
			else 
				c2=1;
            end
        end
        for j=1:64
				if v((i-1),(mod((j-1),32)*2+2),2)<=v((i-1),(mod((j-1),32)*2+1),2)
                    temp=mod((j-1),32)*2+2;
                else
                    temp=mod((j-1),32)*2+1;
                end
                
                v(i,j,1)=temp;               
				gg1=mod((floor((j-1)/32)+floor((mod((temp-1),32))/16)+floor((mod((temp-1),16))/8)+floor((mod((temp-1),4))/2)+mod((temp-1),2)),2); %计算gg1，gg2；gg1，gg2是各个状态之间转移时的输出
                gg2=mod((floor((j-1)/32)+floor((temp-1)/32)+floor((mod((temp-1),32))/16)+floor((mod((temp-1),16))/8)+mod((temp-1),2)),2);
                v(i,j,2)=v(i-1,temp,2)+c1*mod((gg1+rx_bits(1,2*(i-2)+1)),2)+c2*mod((gg2+rx_bits(1,2*(i-1))),2);%更新累积的汉明距离     
           
        end
    end
    temp=1;
    for j=2:64
        if v(length(rx_bits)/2+1,j,2)<v(length(rx_bits)/2+1,temp,2)
            temp=j;
        end
    end
    rx_bits(length(rx_bits)/2)=floor((temp-1)/32);
    for i=length(rx_bits)/2:(-1):2
        temp=v(i+1,temp,1);
        rx_bits(i-1)=floor((temp-1)/32);
    end
    out_bits=rx_bits(:,1:length(rx_bits)/2);
end   

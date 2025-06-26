function [index_package,cor_abs] = rx_package_searck(rx_samples)
th=3;
gap=0;
pass=0;
index=1;
barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1];
for i=11:length(rx_samples)
    cor_abs(i)=abs((rx_samples(i-10:i))*barker');
end 
for i=1:length(cor_abs)
    if cor_abs(i)<th
        gap=gap+1;
    elseif cor_abs(i)>th
        if gap<88
            gap=0;
        elseif gap>88
            pass=pass+1;
            temp=i;
            if cor_abs(i+11)>th&cor_abs(i+22)>th&cor_abs(i+33)>th
                index=temp;
            break;
            end
        end
    end
end
index_package=index-10;            


end


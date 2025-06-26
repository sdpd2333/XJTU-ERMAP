function [downsamples_index,rx_downsamples,index,index_best,correlate_abs] = rx_sample_sync( rx_samples_filter )
Barker=[1 -1 1 1 -1 1 1 1 -1 -1 -1];
rx_samples_filter= rx_samples_filter';
c1=max([abs(real(rx_samples_filter)),abs(imag(rx_samples_filter))]);
rx_samples_norm=(rx_samples_filter./c1);
%每11个数据进行一次相关求和
for i=11:length(rx_samples_norm)
    correlate_abs(i)=abs((rx_samples_norm(i-10:i))*Barker');
end 
index=[];
max_index=[];
for j=44:44:length(correlate_abs)
    [~,max_index]=max(correlate_abs(j-43:j));
    index=[index max_index];
end
index_best=1;
for ii=6:length(index)
    if index(ii-5)==index(ii-4)&&index(ii-4)==index(ii-3)&&...
       index(ii-3)==index(ii-2)&&index(ii-2)==index(ii-1)&&...
       index(ii-1)==index(ii)
       index_best=ii-5;
       break;
    end
end
samples_index=index_best+44*(index_best-1);
if  mod(samples_index,4)==0
    downsamples_index=4;
else
    downsamples_index=mod(samples_index,4);
end

rx_downsamples=rx_samples_norm(downsamples_index:4:end);

end
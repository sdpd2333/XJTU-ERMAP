function [out_signal,cor_abs,col,index_s] = rx_package_search(rxdata,local_sync,len_frame,ratio)

    down_sig=reshape(rxdata,ratio,[]);% 假设为4倍过采样
    [m,n]=size(down_sig);
    cor_abs=zeros(m,n);
    len_window=8;%窗口长度
    threshold=0.3;%阈值
    l=0;
    flag=false;
    for j=1:ratio
        signalo=down_sig(j,:);
        N=length(local_sync);
        for coarse_i=N:n
            nor_sig=signalo(coarse_i-N+1:coarse_i)./ ...
                max(abs(signalo(coarse_i-N+1:coarse_i)));% 按最大的模长放缩
            cor_abs(j,coarse_i)=abs(nor_sig*local_sync')/N;
            if (cor_abs(j,coarse_i)>threshold)||(flag==true)
                flag=true;
                l=l+1;
                if l>=len_window
                    break;
                end
            end
        end
        if flag==true
            break;
        end
    end
    if flag==true
        [row,col]=find(cor_abs==max(max(cor_abs(:,1:end/2))));% 保证索引不超出数组边界
%max(max(...))会返回cor_abs中的最大值。如果存在多个最大值，它返回的是第一个最大值的索引。
% 如果有多个相同的最大值，这样的处理可能会丢失一些匹配点。
%使用1:end/2来保证索引不超出数组边界是正确的，但如果cor_abs的列数不是偶数，这个方式可能会导致边界问题，
% 导致访问越界。你应该明确cor_abs的大小，并确保索引操作的有效性。
        figure(10);clf;
        x=1:length(cor_abs(row,:));
        axis equal;
        plot(x,cor_abs(row,:));
        grid on;
        hold on;

        index_s=col-N+1;
        index_e=index_s+len_frame-1;
        out_signal=down_sig(row,(index_s:index_e));
    else
        out_signal=0;
        cor_abs=0;
        col=0;
        index_s=0;
end



% % signali=(real(signal)>0)*2-1;
% % signalq=(imag(signal)>0)*2-1;
% % signalo=signali+1i*signalq;
% signalo=signal;
% 
% L=length(signal);
% N=length(local_sync);
% 
% for i=N:L
%     cor_abs(i)=abs(signalo(i-N+1:i)*local_sync');%correlation相关
% end
% [~,bo]=max(cor_abs(1:length(cor_abs)/2));
% figure(10);clf;
% x=1:length(cor_abs);
% axis equal;
% plot(x,cor_abs);
% % axis([-1.5 1.5 -1.5 1.5]);
% grid on;
% hold on;
% index_s=bo-N+1;
% index_e=index_s+len_frame-1;
% out_signal=signal(index_s:index_e);
end


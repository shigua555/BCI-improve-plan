function [feature_name,feature] = Time_Domain(X)
%时域特征主要提取：过零率，标准差、近似熵，样本熵，AR
% input:X, 3维 EEG数据。其中，第一维是采样点，第二维是通道数量，第三维度是trials大小

[q,p,k]=size(X);   %获取数据的尺寸大小
feature=zeros(k,12*p);   
for i=1:k
    for j=1:p
        %过零率
        ZCR=0;
        for r=1:q-1
            if X(r,j,i)*X(r+1,j,i) <=0
                ZCR= ZCR+1;
            else
                ZCR=ZCR;
            end
        end
        
        % 标准差
        STD = std(X(:,j,i));
        
        %近似熵——借鉴Kijoon Lee写的函数
        r_apen = 0.2*STD;
        APEN = ApEn(2, r_apen, X(:,j,i), 1);
        
        %样本熵——借鉴Kijoon Lee写的函数
        r_sampentropy = 0.2*STD;
        SAMEN = SampEntropy(2, r_sampentropy, X(:,j,i), 1);
        
        %AR
        ar_order = 8;
        AR_temp = aryule(X(:,j,i)',ar_order);
        AR = AR_temp(2:ar_order+1);
        

        feature(i,12*(j-1)+1:12*j) = [ZCR STD APEN SAMEN AR];
        
    end
end
feature_name = ['ZCR \ ','STD \ ','APEN \ ','SAMEN \ ','AR'];
end


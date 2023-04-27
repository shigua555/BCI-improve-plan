function [feature_name,feature] = Spatial_Domain(X,Label,Fs,m,freq_band,Featute_content)
%空域特征主要提取：CSP，HDCA
% input:X, 3维 EEG数据。其中，第一维是采样点，第二维是通道数量，第三维度是trials大小

if contains(Featute_content,'csp')
    k=10;  %互信息选择的特征数量，k不能超过kmax
    [feature_temp,proj,classNum] = FBCSP(X,Label,Fs,m,freq_band); % m为要提取的CSP参数，m不要超过通道数的一半，不然会出现重复特征
    kmax=size(feature_temp,2);
    rank=all_MuI(feature_temp,Label);
    feature.f=feature_temp(:,rank(1:k,2));
    feature.proj = proj;
    feature.classNum = classNum;
    feature_name =  ['fbcsp\'];
end

if contains(Featute_content,'hdca')
    feature = HDCA_train(w_blocknum,X,Label);
    feature_name =  ['hdca\'];
end

end


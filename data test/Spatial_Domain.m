function [feature_name,feature] = Spatial_Domain(X,Label,Fs,m,freq_band,Featute_content)
%空域特征主要提取：CSP，HDCA
% input:X, 3维 EEG数据。其中，第一维是采样点，第二维是通道数量，第三维度是trials大小

if contains(Featute_content,'csp')
    feature = FBCSP(X,Label,Fs,m,freq_band);
    feature_name =  ['fbcsp\'];
end

if contains(Featute_content,'hdca')
    feature = HDCA_train(w_blocknum,X,Label);
    feature_name =  ['fbcsp\'];
end

end


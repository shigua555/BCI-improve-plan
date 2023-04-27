%author:mao date:2020-10-8 
%programme:the Filter Bank Common Sptial Pattern algorithm
%input:train_data, 3维 EEG数据。其中，第一维是采样点，第二维是通道数量，第三维度是trials大小
%      train_label,train_data对应的标签
%      sampleRate,采样率
%               m,CSP的-m参数，m不要超过通道数的一半，不然会出现重复特征
%output:features_train 融合后各子频带后的特征数组
%       projMAll 由各子频带计算所得的投影矩阵
%       classNum 待分类的类别数量
function [features_train,projM_All,classNum]=FBCSP(train_data,train_label,sampleRate,m,freq)
[~,p,k]=size(train_data);   %获取总的trial次数
%% acquire and combine feature of different frequency bands
features_train=[];          %声明训练集csp特征融合数组
filter_data=zeros(size(train_data));
classNum=max(train_label);  %获取类别数量
projM_All=zeros(p,p,max(train_label)*(size(freq,2)-1)); %申请投影矩阵空间
for i=1:size(freq,2)
    lower=freq(i);  %获取低频
    if lower==freq(size(freq,2))
        break;
    end
    higher=freq(i+1);%获取高频
    %对各子频带进行滤波
    filter_tmp=[];
    for j=1:k   %对每个trial进行循环滤波
        filter_tmp=filter_param(train_data(:,:,j),lower,higher,sampleRate);
        filter_data(:,:,j)=filter_tmp;
    end
    % 计算csp滤波器，用csp滤波器进行特征提取
    projM=cspProjMatrix(filter_data,train_label); %要循环保存投影矩阵用于在线CSP滤波
    projM_All(:,:,1+(i-1)*classNum:i*classNum)=projM;   %存储当前频带投影矩阵
    feature=[];  %声明本子频带特征矩阵
    for b=1:k    %循环提取特征
        feature(b,:)=cspFeature(projM,filter_data(:,:,b),m); %第三个参数m不要超过通道数的一半，不然会出现重复特征
    end
    tmp_data=feature;
    features_train=[features_train,tmp_data]; %拼接各频带特征矩阵
end

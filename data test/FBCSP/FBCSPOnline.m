%author:mao date:2020-10-8
%programme:the Filter Bank Common Sptial Pattern algorithm
%input:train_data,3维 EEG数据。其中，第一维是采样点，第二维是通道数量，第三维度是trials大小
%                 2维 EEG数据。其中，第一位是采样点，第二维是通道数量
%      projMAll,  由训练集计算所得个子频带CSP投影矩阵
%      classNum,  待分类的类别数
%      sampleRate,采样率
%               m,CSP的m参数
%output:features, 融合后各子频带后的特征数组
function features_train=FBCSPOnline(train_data,projMAll,classNum,sampleRate,m,freq)
if ndims(train_data)==3 %输入EEG数据为3维
    %% acquire and combine feature of different frequency bands
    [q,p,k]=size(train_data);%获取总的trial次数
    filter_data=zeros(size(train_data));
    features_train=[];      %声明训练集csp特征融合数组
    for i=1:size(freq,2)
        lower=freq(i);  %获取低频
        if lower==freq(size(freq,2))
            break;
        end
        higher=freq(i+1);%获取高频
        %对各子频带进行滤波
        filter_tmp=[];
        for j=1:k   %对每个trial进行循环滤波,matlab中的filter()函数可以滤波3维数据？
            filter_tmp=filter_param(train_data(:,:,j),lower,higher,sampleRate,4);
            filter_data(:,:,j)=filter_tmp;
        end
        feature=[];  %声明本子频带特征矩阵
        for b=1:k    %循环提取特征
            feature(b,:)=cspFeature(projMAll(:,:,1+(i-1)*classNum:i*classNum),filter_data(:,:,b),m); %第三个参数m不要超过通道数的一半，不然会出现重复特征
        end
        tmp_data=feature;
        features_train=[features_train,tmp_data]; %拼接个自频带特征矩阵
    end
else                  
    %% 输入EEG数据为2维
    features_train=[];      %声明训练集csp特征融合数组
    for i=1:size(freq,2)
        lower=freq(i);  %获取低频
        if lower==freq(size(freq,2))
            break;
        end
        higher=freq(i+1);%获取高频
        %对各子频带进行滤波
        filter_data=filter_param(train_data,lower,higher,sampleRate,4);
        feature=[];  %声明本子频带特征矩阵
        feature=cspFeature(projMAll(:,:,1+(i-1)*classNum:i*classNum),filter_data,m); %第三个参数m不要超过通道数的一半，不然会出现重复特征
        tmp_data=feature';
        features_train=[features_train,tmp_data]; %拼接个自频带特征矩阵
    end
end

function feature=cspFeature(projM,x,m)
%%%%%%通过投影矩阵进行特征提取
% 输入参数：
%      projM: csp投影矩阵
%          x: 一个时间窗口的2维EEG数据。其中，第一维是采样点；第二维是通道
%          m: 投影数据矩阵的第一列和最后一列的个数。
% 输出参数：
%    feature: 从列向量中提取到的特征


classNo=length(projM(1,1,:));  %获取类别数量
channelNo=size(x,2);           %获取通道数量
feature=[];                    %声明特征矩阵
for k=1:classNo                %classNo为类数量
    Z=x*projM(:,:,k); %projected data matrix
    for j=1:m
        feature=[feature; var(Z(:,j)); var(Z(:,channelNo-j+1))];  %var(A) 算矩阵A没列方差，此时默认是除N-1
        %variances of the first and last m columns(第1和最后m列的方差)
    end
end
feature=log(feature/sum(feature)); 


function projM=cspProjMatrix(x,y)
%基于共空间模式算法计算出一个投影矩阵
%输入参数：
%        x:3维 EEG数据。其中，第一维是采样点，第二维是通道数量，第三维度是trials大小
%        y: 一维列向量标签 范围是从1到分类数量，长度与x的第三维保持一致
%注意：这里y标签只能从1开始，往后延，不能用-1 1这种标签格式

trialNo=length(y); %获取标签长度
classNo=max(y);    %获取标签类别数量
channelNo=length(x(1,:,1)); %获取通道数量

for k=1:classNo    %对每一类进行训练
    N_a=sum(y==k); %number of trials for class k，当前类的trials数量
    N_b=trialNo-N_a;
    R_a=zeros(channelNo,channelNo); %申请[通道数量*通道数量] 方阵大小的空间
    R_b=zeros(channelNo,channelNo);
    for i=1:trialNo
        if numel(find(isnan(x(:,:,i))))
           x(:,:,i)= fillmissing(x(:,:,i),'linear',2,'EndValues','nearest');
           x(:,:,i)= fillmissing(x(:,:,i),'nearest');
        else
            x(:,:,i) = x(:,:,i);
        end
        R=x(:,:,i)'*x(:,:,i); 
        %R=cov(x(:,:,i)); 
        R=R/trace(R);
        if y(i)==k   %当前类
            R_a=R_a+R;
        else         %其他类
            R_b=R_b+R;
        end
    end
    R_a=R_a/N_a;
    R_b=R_b/N_b;
    [V,D]=svd(R_a+R_b);  %矩阵奇异值分解
    W=D^(-0.5)*V';       %P白化矩阵，P矩阵返回为W
    S_a=W*R_a*W';
    [V,D]=svd(S_a);
    projM(:,:,k)=W'*V;  %投影矩阵， 最后投影矩阵的大小为 [通道数量 通道数量 类别数量] 其中第三维度为每个类的滤波器
end 

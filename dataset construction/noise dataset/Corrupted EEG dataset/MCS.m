function [x] = MCS(x,p,s1,s2,c,eog_artifacts)
%UNTITLED Missing Channel Simulation
%   模拟缺失通道函数：一共有三种类型的缺失：1）脑电膏干涸导致阻值变大；2）运动伪迹：包含眼动伪迹和面部肌肉伪迹；
% x 是需要通道缺失模拟的样本； p 是通道缺失的概率； s1和s2 是样本的大小参数

yita=0.5+0.5.*rand([1 1]);  
%lmuda=rms(x(:,p))/(rms(eog_artifacts)*(10^(SNR/10)));
missing_channel=binornd(1,p,s1,s2);
position = find(missing_channel);
artifacts_type=randi([1,3],1,length(position));
for w=1:length(position)
    switch artifacts_type(w)
        case 1
            x(:,w)=(1-yita) * x(:,w) + yita * wgn(750,1,-100)*10^6;
        case 2
            x(:,w)=(1-yita) * x(:,w)+ yita *  eog_artifacts;
        case 3
            x(:,w)=(1-yita) * x(:,w)+ yita *  emg_artifacts;
    end
end
end

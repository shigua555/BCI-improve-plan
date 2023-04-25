function [Feture_candidates] = extract_feature(X,Fs,windows_len,step,F_type,Freq_Band)
%  extract_feature 该函数用于提取所给数据的不同类型特征
%  X为输入数据，是一个结构，包含eegdata和label两种属性
%  Fs为数据的采集频率
%  F_type为所需要提取数据特征的类型，1为时域特征；2为频域/时频特征；3为空域特征；4为混合特征；
%  P为是否需要执行PCA

for i=1:length(X)
    EEG=[];
    d0=1;
    for j=1:length(X(i).eegdata)
        if step == 0
            x=X(i).eegdata{j,1}(:,1:22);
            EEG(i).data(:,:,d0)=x;
            EEG(i).y(d0)=X(i).label(j);
            d0=d0+1;
        else
            m0=fix((length(X(i).eegdata{j,1})-windows_len)/step)+1;
            for b=1:m0
                x=X(i).eegdata{j,1}(1+step*(b-1):windows_len+step*(b-1),1:22);
                EEG(i).data(:,:,d0)=x;
                EEG(i).y(d0)=X(i).label(j);
                d0=d0+1;
            end
        end
    end
        EEG(i).sr=Fs;
        %计算各种特征
        switch F_type
            case 1  %时域特征主要提取：过零率，标准差、近似熵，样本熵，AR
                disp(['时域特征计算中...']);
                tic;
                [Feture_candidates(i).TFname,Feture_candidates(i).TF] = Time_Domain(EEG(i).data);
                t_freq_candidate_cost = toc;
                disp(['时域特征计算完毕，耗时(秒)： ',num2str(t_freq_candidate_cost)]);
            case 2  %频域以及时频域特征主要提取：频带能量，频带能量占比，平均功率谱密度，功率谱密度占比，微分熵，本征模态函数
                disp(['频域特征计算中...']);
                tic;
                [Feture_candidates(i).TFFname,Feture_candidates(i).TFF] = Timefrequency_Domain(EEG(i).data,EEG(i).sr,Freq_Band);
                t_freq_candidate_cost = toc;
                disp(['频域特征计算完毕，耗时(秒)： ',num2str(t_freq_candidate_cost)]);
            case 3  %空域特征主要提取：
                disp(['空域特征计算中...']);
                tic;
                [Feture_candidates(i).SDname,Feture_candidates(i).SD] = Spatial_Domain(EEG(i).data);
                t_freq_candidate_cost = toc;
                disp(['空域特征计算完毕，耗时(秒)： ',num2str(t_freq_candidate_cost)]);
            case 4  %混合特征
                Feture_candidates(i).All = ALL(EEG);
        end
end
    

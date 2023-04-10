function [Y] = corrupted_EEG_databuild(X,N_EMG,N_EOG,fs,p)
%UNTITLED 构建坏道EEG数据集
%   X为需要构建的数据集，Y为按照要求构建的坏道EEG数据集，数据类型为struct；
%   N_EMG为肌电噪声数据集，N_EOG为眼电噪声数据集；
%   fs为数据集采样率；p为坏道比例；
%   肌电噪声的采样率为512Hz，眼电噪声的采样率为256Hz(直接假设512Hz)
[a_EMG,~]=size(N_EMG); [a_EOG,~]=size(N_EOG);
SNR_EMG = -5; SNR_EOG = -5;
SNR_B = -3; %对应30kΩ的阻值

for choose_num=1:length(X)
    for movement_num=1:length(X(choose_num).eegdata)
        [a,b]=size(X(choose_num).eegdata{movement_num,1});
        missing_channel=binornd(1,p,1,b);
        position = find(missing_channel);
        noise_type=randi([1,4],1,length(position)); % noise_type一共有四种类型：空值，眼电噪声，肌电噪声，白噪声（模拟脑电膏不够或者干涸导致的通道阻值过大）
        x=X(choose_num).eegdata{movement_num,1};
        
        %生成随机噪声,每个脑电信号片段的每个通道都会随机生成噪声进行添加
         t=a/fs; 
%         noise_emg=[]; noise_eog=[];
%         emg_choose_num=randi([1,a_EMG],1,t);
%         eog_choose_num=randi([1,a_EOG],1,t);
%         for i=1:t
%            noise_emg= [noise_emg EMG_all_epochs(emg_choose_num(i),:)];
%            noise_eog= [noise_eog EOG_all_epochs(eog_choose_num(i),:)];
%         end
%         Noise_EMG = resample(noise_emg,fs,512); %512Hz为肌电和眼电噪声的采样率；
%         Noise_EOG = resample(noise_eog,fs,512); 
        
        % 加入随机噪声，每个脑电信号片段的每个通道都会随机生成噪声进行添加
        for w=1:length(position)
            noise_emg=[]; noise_eog=[]; Noise_EMG=[]; Noise_EOG=[];
            switch noise_type(w)
                case 1  % 加入肌电噪声
                    emg_choose_num=randi([1,a_EMG],1,t);
                    for i=1:t
                        noise_emg= [noise_emg N_EMG(emg_choose_num(i),:)];
                    end
                    Noise_EMG = resample(noise_emg,fs,512);
                    lmuda_emg=rms(x(:,w))/(rms(Noise_EMG)*10^(SNR_EMG/10));
                    x(:,w)=x(:,w) + (lmuda_emg * Noise_EMG)';
                case 2  % 加入眼电噪声
                    eog_choose_num=randi([1,a_EOG],1,t);
                    for i=1:t
                        noise_eog=[noise_eog N_EOG(eog_choose_num(i),:)];
                    end
                    Noise_EOG = resample(noise_eog,fs,512);
                    lmuda_eog=rms(x(:,w))/(rms(Noise_EOG)*10^(SNR_EOG/10));
                    x(:,w)=x(:,w) + (lmuda_eog * Noise_EOG)';
                case 3  % 加入白噪声
                    x(:,w)=awgn(x(:,w),SNR_B);
                case 4  % 加入空值
                    x(:,w)=zeros(length(x(:,w)),1);
            end
        end
        X(choose_num).eegdata{movement_num,1}=x;
    end
end
Y=X;
end


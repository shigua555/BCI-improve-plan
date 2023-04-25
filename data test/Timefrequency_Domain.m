function [feature_name,feature] = Timefrequency_Domain(X,Fs,freq_band)
%频域以及时频域特征主要提取：频带能量，频带能量占比，平均功率谱密度，功率谱密度占比，微分熵，本征模态函数
% input:X, 3维 EEG数据。其中，第一维是采样点，第二维是通道数量，第三维度是trials大小

[q,p,k]=size(X);   %获取数据的尺寸大小
if (mod(q,5)==0)
    nfft = q/5;
else
    nfft = q/4;
end
noverlap = nfft/2;
imf_level = 2;
feature = [];
for i=1:k
    for j=1:p
        %频带能量特征
        fft_temp = []; 
        fft_temp = abs(fft(X(:,j,i)',Fs))/length(X(:,j,i));
        band_sum = [];
        for r = 1:length(freq_band)-1
            fft_sum_temp = sum(fft_temp(:, freq_band(r):freq_band(r+1))');
            band_sum = [band_sum fft_sum_temp];
        end
        
        %频带能量占比
        total_bandenergy = sum(band_sum);
        band_energy_rate = band_sum/total_bandenergy;
        
        %功率谱密度
        px=[];
        [px,~]=pwelch(X(:,j,i)',hanning(nfft),noverlap,nfft,Fs);
        average_band_psd=[];
        for r = 1:length(freq_band)-1
            psd_temp = sum(px(freq_band(r):freq_band(r+1)))/(freq_band(r+1)-freq_band(r));
            average_band_psd = [average_band_psd psd_temp];
        end
        
        %功率谱密度占比
        total_psd = sum(average_band_psd);
        band_psd_rate = average_band_psd/total_psd;
        
        %微分熵
        de = log2(average_band_psd);
        
        % 时频特征：本征模态算法（EMD） + 微分熵
        fft_temp = [];
        imf_temp = [];
        emdf = [];
        imf_temp = emd(X(:,j,i),'Interpolation','pchip','MaxNumIMF',imf_level,'Display',0);
        fft_temp = abs(fft(imf_temp(:,imf_level)',Fs))/length(X(:,j,i));
        for r = 1:length(freq_band)-1
            EMD_fft_temp = sum(fft_temp(:, freq_band(r):freq_band(r+1))');
            emdf = [emdf EMD_fft_temp];
        end
        emd_de = log2(emdf);
        
        L = length([band_sum band_energy_rate average_band_psd band_psd_rate de emdf emd_de]);
        feature(i,L*(j-1)+1:L*j) = [band_sum band_energy_rate average_band_psd band_psd_rate de emdf emd_de];
    end
end
      feature_name = ['Band_Energy \ ','Band_Energy_Rate \ ','PSD \ ','PSD_Rate \ ','DE \ ','EMD \ ','EMD_DE'];  
end




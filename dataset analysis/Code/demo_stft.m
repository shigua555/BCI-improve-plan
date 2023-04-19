%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  This is the demo script to calculate the short-time Fourier 
%               transform (STFT) of a MI signal.

%% load data and define parameters
clear all; clc;

load('E:\研究工作\BCI-improve-plan\dataset construction\self dataset\LLMBCImotion.mat')

choose_num = 1; choose_movement = 2; choose_channle = 17; % 或者17（C3和C4通道）
x = s_train(choose_num).eegdata{choose_movement,1}(:,choose_channle);

Fs = 250;
t = 3/750:3/750:3;
%   - x: the MI signal (750 time points, averaged from multiple trials)
%   - Fs: the sampling rate (Fs = 250Hz)


N = numel(x); % the number of time points

%% perform time-frequency analysis using STFT
nfft = 2^nextpow2(N); % the number of FFT points
winsize = round([0.2 0.4 0.8]*Fs); % three window sizes (0.2s, 0.4s, 08s) are used in STFT for comparison
for n=1:numel(winsize)
    [P(:,:,n),f] = subfunc_stft(x, winsize(n), nfft, Fs);
end

%% display MI and STFT results with different window sizes
f_lim = [min(f(f>0)), 30]; % specify the frequency range to be shown (remove 0Hz)
f_idx = find((f<=f_lim(2))&(f>=f_lim(1)));
t_lim = [0, 3]; % specify the time range to be shown
t_idx = find((t<=t_lim(2))&(t>=t_lim(1)));

figure('units','normalized','position',[0.1    0.15    0.8    0.7])
subplot(2,2,1)
hold on; box on
plot(t(t_idx),x(t_idx),'k','linewidth',1);
set(gca,'xlim',[min(t_lim),max(t_lim)])
xlabel('Time (s)')
ylabel('Amplitude (\muV)')
title(['MI'],'fontsize',12)
for n=1:numel(winsize)
    subplot(2,2,n+1)
    imagesc(t(t_idx),f(f_idx),P(f_idx,t_idx,n))
    xlabel('Time (s)')
    ylabel('Frequency (Hz)')
    set(gca,'xlim',t_lim,'ylim',f_lim)
    axis xy; hold on;
    plot([0 0],[0 Fs/2],'w--')
    text(t_lim(2),f_lim(2)/2,'Power (dB)','rotation',90,'horizontalalignment','center','verticalalignment','top')
    title(['Spectrogram (winsize = ',num2str(winsize(n)/Fs,'%1.2g'),'s)'],'fontsize',12)
    colorbar
end

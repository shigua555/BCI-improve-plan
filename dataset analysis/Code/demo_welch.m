%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:  This is the demo script to estimate the spectrum of an
%               EEG signal using the Welch's method.

%% load data and define parameters
clear all; clc;

load('E:\研究工作\BCI-improve-plan\dataset construction\self dataset\LLMBCImotion.mat')

%   - x: the EEG signal (with eyes-closed)
%   - Fs: the sampling rate

choose_num = 1; choose_movement = 2; choose_channle = 17; % 或者17（C3和C4通道）
x = s_train(choose_num).eegdata{choose_movement,1}(:,choose_channle);
Fs = 250;


N = length(x); % the number of samples (N=480)
x = detrend(x); % remove the low-frequency trend from EEG

%% spectral estimation (the Welch's method)
nfft = 2^nextpow2(N); % the number of FFT points
[P_per, f] = periodogram(x,[],nfft,Fs); % periodogram is also estimated for comparison
% check the help file to learn how to specify parameters in "pwelch.m"
% three parameter settings are used below
[P_wel_1, f] = pwelch(x,Fs,Fs/2,nfft,Fs);
[P_wel_2, f] = pwelch(x,Fs,0,nfft,Fs);
[P_wel_3, f] = pwelch(x,Fs/2,0,nfft,Fs);

%% display spectral estimates
f_lim = f((f>0)&(f<=40)); % specify the frequency range to be shown

figure('units','normalized','position',[0.1    0.3    0.8    0.5])
subplot(1,2,1)
hold on; box on;
plot(f,10*log10(P_per),'k','linewidth',0.5)
plot(f,10*log10(P_wel_1),'r','linewidth',2)
xlabel('Frequency (Hz)'); ylabel('Power (dB)')
hl = legend('Periodogram','Welch''s method (M=250, D=125)');
set(hl,'box','off','location','southwest')
set(gca,'xlim',[min(f_lim),max(f_lim)])

subplot(1,2,2)
hold on; box on;
plot(f,10*log10(P_wel_1),'r','linewidth',2)
plot(f,10*log10(P_wel_2),'g','linewidth',1)
plot(f,10*log10(P_wel_3),'b','linewidth',1)
xlabel('Frequency (Hz)'); ylabel('Power (dB)')
hl = legend('Welch''s (M=250, D=125)','Welch''s (M=250, D=0)','Welch''s (M=125, D=0)');
set(hl,'box','off','location','southwest')
set(gca,'xlim',[min(f_lim),max(f_lim)])

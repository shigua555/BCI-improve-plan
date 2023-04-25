clear all; clc;

load('E:\研究工作\BCI-improve-plan\dataset construction\public dataset\BCICIV2a.mat'); %加载数据

fs = 250;
freq_band = [1,4,8,12,30,60];

train_data = extract_feature(s_train,fs,750,0,2,freq_band);
test_data = extract_feature(s_test,fs);
 
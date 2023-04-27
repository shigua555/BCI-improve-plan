%% 对数据进行滤波
%输入：data 待滤波EEG数据
%   low        高通滤波参数设置
%   high       低通滤波参数设置
%   sampleRate          采样率
%返回：filterdata       滤波后EEG数据
function filterdata=filter_param(data,low,high,sampleRate)
%% 设置滤波参数
 Hd = bandpass_filter(low,high,sampleRate);
 filterdata= filter(Hd.Numerator,1,data);

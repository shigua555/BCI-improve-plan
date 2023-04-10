clear;clc;

root_dir = 'E:\研究工作\BCI狂暴进阶计划\数据集构建\自用数据集\EEG\';
file_name_signal = dir(root_dir);
load('EEG_bandpass.mat'); %1-40HZ的带通滤波器参数设置，后续处理并未添加

for k=1:3
    random_seed(k,:)=randsample(30,21);
end
for index=3:length(file_name_signal)
    [file_path, file_namea, file_ext] = fileparts(file_name_signal(index).name);
    fd = strcat(root_dir, file_namea);
    file_name_subject = dir(fd);
    num=1; num1=1;
    for indexb=3:length(file_name_subject)
        [file_path, file_nameb, file_ext] = fileparts(file_name_subject(indexb).name);
        fdb= strcat(fd, '\');
        fdb = strcat(fdb, file_nameb);
        file_name_movement = dir(fdb);
        for indexc=3:length(file_name_movement)
            [file_path, file_namec, file_ext] = fileparts(file_name_movement(indexc).name);
            fdc= strcat(fdb, '\');
            fdc = strcat(fdc, file_namec,'.csv');
            
            delimiterIn=',';
            headerlinesIn=1;
            csv_file = importdata(fdc, delimiterIn, headerlinesIn);
            if ismember(str2num(file_namec),random_seed(indexb-2,:))
                s_train(index-2).name = file_namea;
                s_train(index-2).title = csv_file.textdata;
                if(iscell(csv_file))
                    s_train(index-2).eegdata{num,1}=[];
                    pause;
                else
                    get_data = resample(csv_file.data(2001:5000,:)*10^6,250,1000);
                    s_train(index-2).eegdata{num,1}=get_data;
                    switch file_nameb
                        case {'sit'}
                            s_train(index-2).label(num,1)=2;
                        case {'stand'}
                            s_train(index-2).label(num,1)=3;
                        case {'walk'}
                            s_train(index-2).label(num,1)=1;
                    end
                    num=num+1;
                end
            else
                s_test(index-2).name = file_namea;
                s_test(index-2).title = csv_file.textdata;
                if(iscell(csv_file))
                    s_test(index-2).eegdata{num1,1}=[];
                    pause;
                else
                    get_data = resample(csv_file.data(2001:5000,:)*10^6,250,1000);
                    s_test(index-2).eegdata{num1,1}=get_data;
                    switch file_nameb
                        case {'sit'}
                            s_test(index-2).label(num1,1)=2;
                        case {'stand'}
                            s_test(index-2).label(num1,1)=3;
                        case {'walk'}
                            s_test(index-2).label(num1,1)=1;
                    end
                    num1=num1+1;
                end
            end
        end
    end
end

for i=1:length(s_train)
    rowrank = randperm(size(s_train(i).eegdata, 1));
    for j=1:size(s_train(i).eegdata, 1)
        eegdata{j,1}=s_train(i).eegdata{rowrank(j),1};
        label(j,1)=s_train(i).label(rowrank(j),1);
    end
    s_train(i).eegdata=eegdata;
    s_train(i).label=label;
end

save_filename=('E:\研究工作\BCI狂暴进阶计划\数据集构建\自用数据集\LLMBCImotion.mat');
save(save_filename,'s_train','s_test');
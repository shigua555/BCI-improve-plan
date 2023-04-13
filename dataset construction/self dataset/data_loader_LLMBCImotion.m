clear;clc;

root_dir = 'E:\研究工作\BCI-improve-plan\dataset construction\self dataset\EEG\';
file_name_signal = dir(root_dir);
load('EEG_bandpass.mat'); %1-40HZ的带通滤波器参数设置，后续处理并未添加

data_type = 2;   % data_type 表示需要的数据类型，1表示within-subject, 2表示cross-subject
data_spalit_rate = 0.7;  % 训练集和测试集比例，默认7：3
trainset_num = 7;  testset_num = 3; % 训练集和测试集所包含受试者的数量


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
            s(index-2).name = file_namea;
            s(index-2).title = csv_file.textdata;
            if(iscell(csv_file))
                s(index-2).eegdata{num,1}=[];
                pause;
            else
                get_data = resample(csv_file.data(2001:5000,:)*10^6,250,1000);
                s(index-2).eegdata{num,1}=get_data;
                switch file_nameb
                    case {'sit'}
                        s(index-2).label(num,1)=2;
                    case {'stand'}
                        s(index-2).label(num,1)=3;
                    case {'walk'}
                        s(index-2).label(num,1)=1;
                end
                num=num+1;
            end
        end
    end
end

switch data_type
    case 1
        v=1;
        everyclass_number = length(s(1).eegdata)/length(unique(s(1).label));
        train_number = ceil(everyclass_number * data_spalit_rate);
        for i = 1:length(s)
            d=1;
            for j=1:length(unique(s(i).label))
                ind=find(s(i).label==j);
                choose_index = randsample(1:everyclass_number,train_number);
                for k=1:train_number
                    sub_lab_ind(v,d) = ind(choose_index(k));
                    d=d+1;
                end
            end
            v=v+1;
        end
        
        
        k=1;
        for i = 1:length(s)
            train_num = 1;
            test_num = 1;  
            for j = 1:length(s(i).eegdata)
                x=s(i).eegdata{j,1};
                if ismember(j, sub_lab_ind(k,:))
                    s_train(k).eegdata{train_num,1}=x;
                    s_train(k).label(train_num,1) = s(i).label(j);
                    train_num = train_num+1;
                else
                    s_test(k).eegdata{test_num,1}=x;
                    s_test(k).label(test_num,1) = s(i).label(j);
                    test_num = test_num+1;
                end
            end
            k=k+1;
        end
        
    case 2
        subject_set = [1:10];
        randnum=randperm(length(subject_set)); %随机产生矩阵位置
        subject_trainset = subject_set(randnum(1:trainset_num));
        subject_testset = subject_set(randnum(trainset_num+1:trainset_num+testset_num));
        train_k=1; test_k=1;
        for i = 1:length(s)
            if ismember(i,subject_trainset)
                for j = 1:length(s(i).eegdata)
                    s_train(train_k).eegdata{j,1}=s(i).eegdata{j,1};
                    s_train(train_k).label(j,1) = s(i).label(j);
                end
                train_k = train_k+1;
            elseif ismember(i,subject_testset)
                for j = 1:length(s(i).eegdata)
                    s_test(test_k).eegdata{j,1}=s(i).eegdata{j,1};
                    s_test(test_k).label(j,1) = s(i).label(j);
                end
                test_k = test_k+1;
            end
        end
end

save_filename=('E:\研究工作\BCI-improve-plan\dataset construction\self dataset\LLMBCImotion.mat');
save(save_filename,'s_train','s_test');
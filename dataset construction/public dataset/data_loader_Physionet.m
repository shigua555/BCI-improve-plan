clear; clc;

root = 'E:\研究工作\BCI-improve-plan\dataset construction\public dataset\Motor Movement Imagery dataset\109-Subjects\Dataset\';
root1 = 'E:\研究工作\BCI-improve-plan\dataset construction\public dataset\Motor Movement Imagery dataset\109-Subjects\Labels\';
namelist = dir([root,'*.mat']);
labellist = dir([root1,'*.mat']);
L=length(namelist);
Wrong = [];
count = 1;
data_type = 2;   % data_type 表示需要的数据类型，1表示within-subject, 2表示cross-subject
data_spalit_rate = 0.7;  % 训练集和测试集比例，默认7：3
trainset_num = 20;  testset_num = 5; % 训练集和测试集所包含受试者的数量

for j=1:L
    Name{j,1}=namelist(j).name;
    Label_Name{j,1}=labellist(j).name;
end

for i=1:L
    order = ['Dataset_',num2str(i),'.mat'];
    label_order = ['Labels_',num2str(i),'.mat'];
    [index,~] = find(strcmp(Name, order));
    [label_index,~] = find(strcmp(Label_Name, label_order));
    load([root,namelist(index).name]);
    load([root1,labellist(label_index).name]);
    [a,b,~] = size(Dataset);
    for subject = 1:a
        for movement_count = 1:b
            s(subject).eegdata{movement_count,1}(:,i) = squeeze(Dataset(subject,movement_count,:));
            lab = find(squeeze(Labels(subject,movement_count,:)) == 1);
            if i==1
                s(subject).label(movement_count,1) = lab;
            else
                if lab ~= s(subject).label(movement_count,1)
                    Wrong(count) = i;
                    count = count+1;
                end
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
            if ismember(i,[88,89,92,100,104])
            else
                d=1;
                for j=1:4
                    ind=find(s(i).label==j);
                    choose_index = randsample(1:everyclass_number,train_number);
                    for k=1:train_number
                        sub_lab_ind(v,d) = ind(choose_index(k));
                        d=d+1;
                    end
                end
                v=v+1;
            end
        end
        
        
        k=1;
        for i = 1:length(s)
            train_num = 1;
            test_num = 1;
            if ismember(i,[88,89,92,100,104])
            else
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
        end
        
    case 2
        subject_set = [1:87,90,91,93:99,101:103,105:109];
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

save_filename=['E:\研究工作\BCI-improve-plan\dataset construction\public dataset\','Physionet.mat'];
save(save_filename,'s_train','s_train');

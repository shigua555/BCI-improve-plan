clear;clc;

root_dir0 = 'E:\研究工作\BCI-improve-plan\dataset construction\public dataset\BCI_IV_2a dataset\true_labels\'; %初始标签路径
root_dir = 'E:\研究工作\BCI-improve-plan\dataset construction\public dataset\BCI_IV_2a dataset\data\'; %初始数据路径

file_eeg_signal = dir(root_dir);
i=1; j=1;
for index=3:length(file_eeg_signal)
    [file_path, file_namea, file_ext] = fileparts(file_eeg_signal(index).name);
    fd = strcat(file_namea,'.gdf');
    label_fd = strcat(root_dir0,file_namea,'.mat');
    s=[]; h=[]; l=[]; m=1; n=1; o=1; u=1;
    [s,h]=sload(fd);
    l=load(label_fd);
    if contains(fd,'E')
        for k=1:length(h.EVENT.TYP)
            switch (h.EVENT.TYP(k))
                case {32766,1023,768}
                    continue;
                case 276
                    s_test(i).eyedata{m,1}=s(h.EVENT.POS(k):(h.EVENT.POS(k)+h.EVENT.DUR(k)-1),:);
                    m=m+1;
                case 277
                     s_test(i).eyedata{n,2}=s(h.EVENT.POS(k):(h.EVENT.POS(k)+h.EVENT.DUR(k)-1),:);
                     n=n+1;
                case 1072
                     s_test(i).eyedata{o,3}=s(h.EVENT.POS(k):(h.EVENT.POS(k)+h.EVENT.DUR(k)-1),:);
                     o=o+1;
                case {783,769,770,771,772}
                    x0=[]; x1=[]; x2=[];
                    x1=s(h.EVENT.POS(k)+250:(h.EVENT.POS(k)+1000-1),:);
                    if numel(find(isnan(x1))) == 0
                        x0 = x1;
                    else
                        x2 = fillmissing(x1,'linear',2,'EndValues','nearest');
                        x0= fillmissing(x2,'nearest');
                    end
                    s_test(i).eegdata{u,1} = x0;
                    u=u+1;
            end
        end
        s_test(i).title=h.Label';
        s_test(i).label=l.classlabel;
        i=i+1;
    else
        for k=1:length(h.EVENT.TYP)
            switch (h.EVENT.TYP(k))
                case {32766,1023,768}
                    continue;
                case 276
                    s_train(j).eyedata{m,1}=s(h.EVENT.POS(k):(h.EVENT.POS(k)+h.EVENT.DUR(k)-1),:);
                    m=m+1;
                case 277
                    s_train(j).eyedata{n,2}=s(h.EVENT.POS(k):(h.EVENT.POS(k)+h.EVENT.DUR(k)-1),:);
                    n=n+1;
                case 1072
                    s_train(j).eyedata{o,3}=s(h.EVENT.POS(k):(h.EVENT.POS(k)+h.EVENT.DUR(k)-1),:);
                    o=o+1;
                case {783,769,770,771,772}
                    x0=[]; x1=[]; x2=[];
                    x1=s(h.EVENT.POS(k)+250:(h.EVENT.POS(k)+1000-1),:);
                    if numel(find(isnan(x1))) == 0
                        x0 = x1;
                    else
                        x2 = fillmissing(x1,'linear',2,'EndValues','nearest');
                        x0= fillmissing(x2,'nearest');
                    end
                    s_train(j).eegdata{u,1} = x0;
                    u=u+1;
            end
        end
        s_train(j).title=h.Label';
        s_train(j).label=l.classlabel;
        j=j+1;
    end
end

data_type = 2;   % data_type 表示需要的数据类型，1表示within-subject, 2表示cross-subject
data_spalit_rate = 0.7;  % 训练集和测试集比例，默认7：3
trainset_num = 7;  testset_num = 2; % 训练集和测试集所包含受试者的数量

s = []; dim = 1;
for choose_num = 1:length(s_train)
    s(choose_num).eyedata = [s_train(choose_num).eyedata,s_test(choose_num).eyedata];
    s(choose_num).title = s_train(choose_num).title;
    s(choose_num).eegdata = cat(dim, s_train(choose_num).eegdata, s_test(choose_num).eegdata);
    s(choose_num).label = cat(dim, s_train(choose_num).label, s_test(choose_num).label);
end

switch data_type
    case 1
        if data_spalit_rate == 0
        else
            v=1; s_train = []; s_test = [];
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
        end
    case 2
        subject_set = [1:9]; s_train=[]; s_test=[];
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

save_filename=['E:\研究工作\BCI-improve-plan\dataset construction\public dataset\','BCICIV2a.mat'];
save(save_filename,'s_train','s_test');




clear; clc;

root = 'E:\研究工作\BCI狂暴进阶计划\数据集构建\公开数据集\Motor Movement Imagery dataset\109-Subjects\Dataset\';
root1 = 'E:\研究工作\BCI狂暴进阶计划\数据集构建\公开数据集\Motor Movement Imagery dataset\109-Subjects\Labels\';
namelist = dir([root,'*.mat']);
labellist = dir([root1,'*.mat']);
L=length(namelist);
Wrong = [];
count = 1;

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

% pa=0.5; s1=1; s2=64;
% eog_artifacts= resample([EOG_all_epochs(1,:),EOG_all_epochs(2,:)],160,256)';
% emg_artifacts= resample([EMG_all_epochs(1,:),EMG_all_epochs(2,:)],160,256)'/500;

v=1;
for i = 1:length(s)
    if ismember(i,[88,89,92,100,104])
    else
        d=1;
        for j=1:4
            ind=find(s(i).label==j);
            choose_index = randsample(1:21,14);
            for k=1:14
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
%             x=MCS(s(i).eegdata{j,1},pa,s1,s2,emg_artifacts,eog_artifacts);
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

save_filename=['E:\研究工作\BCI狂暴进阶计划\数据集构建\公开数据集\','Physionet.mat'];
save(save_filename,'s_train','s_train');

% mkdir('E:\研究工作\2022年\IJCAI\code\公用数据集测试\个人数据集划分',num2str(pa));
% for i=1:length(s_train)
%     train = s_train(i);
%     test = s_test(i);
%     save_filename=['E:\研究工作\2022年\IJCAI\code\公用数据集测试\个人数据集划分\',num2str(pa),'\',num2str(i),'.mat'];
%     save(save_filename,'train','test');
% end
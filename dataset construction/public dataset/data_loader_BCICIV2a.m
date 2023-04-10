clear;clc;

root_dir0 = 'E:\研究工作\BCI狂暴进阶计划\数据集构建\公开数据集\BCI_IV_2a dataset\true_labels\'; %初始标签路径
root_dir = 'E:\研究工作\BCI狂暴进阶计划\数据集构建\公开数据集\BCI_IV_2a dataset\data\'; %初始数据路径

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

save_filename=['E:\研究工作\BCI狂暴进阶计划\数据集构建\公开数据集\','BCICIV2a.mat'];
save(save_filename,'s_train','s_test');
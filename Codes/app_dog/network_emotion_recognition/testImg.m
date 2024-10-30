
ifShowImg = 1;

confu_test = 1;

if confu_test
    showData = imgsValidation;
else
    showData = imgsTrain;
end

% showData = shuffle(showData);

showData=showData.splitEachLabel(100);
YoutTest = classify(trainedGN,showData);

[RealAction, RealAffection] = transform(showData.Labels);
[PredAction, PredAffection] = transform(YoutTest);

RealAll = zeros(length(RealAction),1);
PredAll = zeros(length(PredAction),1);
for indAll = 1:length(RealAction)
    RealAll(indAll) = (RealAction(indAll)-1)*3+RealAffection(indAll);
    PredAll(indAll) = (PredAction(indAll)-1)*3+PredAffection(indAll);
end
[X1,Y1,R,AUC]=perfcurve(RealAction, PredAction,1);
[X2,Y2,R,AUC]=perfcurve(RealAffection, PredAffection,1);
[X3,Y3,R,AUC]=perfcurve(RealAll, PredAll,1);


TestLabel_action = [];
YouLabel_action = [];
TestLabel_affection = [];
YouLabel_affection = [];
for i = 1:length(showData.Labels)
    [out1, out2] = split(string(showData.Labels(i)),'_');
    TestLabel_action = [TestLabel_action;out1(1)];
    TestLabel_affection = [TestLabel_affection;out1(2)];
    [out1, out2] = split(string(YoutTest(i)),'_');
    YouLabel_action = [YouLabel_action;out1(1)];
    YouLabel_affection = [YouLabel_affection;out1(2)];
end


accuracy = mean(showData.Labels == YoutTest);

accuracy_action = mean(TestLabel_action == YouLabel_action);
accuracy_affection = mean(TestLabel_affection == YouLabel_affection);
if ifShowImg

    figure(1)
    confusionchart(showData.Labels,YoutTest,'Normalization','row-normalized','FontSize',20)
    figure(2)
    confusionchart(TestLabel_action,YouLabel_action,'Normalization','row-normalized')
    figure(3)
    confusionchart(TestLabel_affection,YouLabel_affection,'Normalization','row-normalized')
        
    act=activations(trainedGN,showData,"new_fc");
    X = reshape(act,size(act,3),size(act,4))';

    probSoftmax=activations(trainedGN,showData,"prob");
    OutSoftmax = reshape(probSoftmax,size(probSoftmax,3),size(probSoftmax,4))';
    
    scores_roc = zeros(length(OutSoftmax),1);
    for tpr = 1:length(OutSoftmax)
        idx_tpr = RealAll(tpr);
        scores_roc(tpr) = OutSoftmax(tpr,idx_tpr);
    end

    % figure (4)
    % rocObj = rocmetrics(showData.Labels,OutSoftmax,unique(showData.Labels));
    % curveObj = plot(rocObj,AverageROCType=["macro"],ClassNames=[]);
    % [FPR,TPR,Thresholds,AUC] = average(rocObj,"macro");

    figure (5)

    % labels = unique(Dataset_Label);
    labels = string(showData.Labels);
    no_dims = 2;
    init_dims = 30;
    perplexity = 30;
    mappedX = tsne(X, NumDimensions = no_dims, Perplexity=perplexity);
    color_gs = ['k','k','k','g','g','g','b','b','b','y','y','y','k','k','k','w','w','w','r','r','r'];
    gscatter(mappedX(:,1), mappedX(:,2), showData.Labels,color_gs)
    label_uniq = unique(showData.Labels);
    map_x = mappedX(:,1);
    map_y = mappedX(:,2);
    for i_label = 1:3:length(label_uniq)
        map_x_i_label = [];
        map_y_i_label = [];
        map_i_label = [];
        for j_label = i_label:i_label+2
            index_j_label = find(showData.Labels == label_uniq(j_label));
            map_x_j_label = map_x(index_j_label);
            map_y_j_label = map_y(index_j_label);
            map_j_label = ones(length(map_x_j_label),1) .* (j_label+1-i_label);
            map_i_label = [map_i_label;map_j_label];
            map_x_i_label = [map_x_i_label;map_x_j_label];
            map_y_i_label = [map_y_i_label;map_y_j_label];
        end
        save(strcat("./SNEMap/map_",string(label_uniq(i_label)),"_x"),"map_x_i_label");
        save(strcat("./SNEMap/map_",string(label_uniq(i_label)),"_y"),"map_y_i_label");
        save(strcat("./SNEMap/map_",string(label_uniq(i_label)),"_z"),"map_i_label");
    end

    % save("mappedX","mappedX");
    % save("mappedXLabel","labels");
    % idx = randperm(size(TestData1,4),9);
end

num = zeros(8,3);
numTotal = zeros(8,3);
accAction = zeros(8,3);
%% 获取手势与情绪的相关性
for i = 1:length(showData.Labels)
    switch TestLabel_action(i)
        case "knock"
            tar = 1;
            switch TestLabel_affection(i)
                case "calm"
                    tar2 = 1;
                case "happy"
                    tar2 = 2;
                case "sad"
                    tar2 = 3;
            end
            num(tar,tar2) = num(tar,tar2)+(YouLabel_affection(i)==TestLabel_affection(i));
            numTotal(tar,tar2) = numTotal(tar,tar2)+1;
        case "pat"
            tar = 2;
            switch TestLabel_affection(i)
                case "calm"
                    tar2 = 1;
                case "happy"
                    tar2 = 2;
                case "sad"
                    tar2 = 3;
            end
            num(tar,tar2) = num(tar,tar2)+(YouLabel_affection(i)==TestLabel_affection(i));
            numTotal(tar,tar2) = numTotal(tar,tar2)+1;
        case "pet"
            tar = 3;
            switch TestLabel_affection(i)
                case "calm"
                    tar2 = 1;
                case "happy"
                    tar2 = 2;
                case "sad"
                    tar2 = 3;
            end
            num(tar,tar2) = num(tar,tar2)+(YouLabel_affection(i)==TestLabel_affection(i));
            numTotal(tar,tar2) = numTotal(tar,tar2)+1;
        case "press"
            tar = 4;
            switch TestLabel_affection(i)
                case "calm"
                    tar2 = 1;
                case "happy"
                    tar2 = 2;
                case "sad"
                    tar2 = 3;
            end
            num(tar,tar2) = num(tar,tar2)+(YouLabel_affection(i)==TestLabel_affection(i));
            numTotal(tar,tar2) = numTotal(tar,tar2)+1;
        case "push"
            tar = 5;
            switch TestLabel_affection(i)
                case "calm"
                    tar2 = 1;
                case "happy"
                    tar2 = 2;
                case "sad"
                    tar2 = 3;
            end
            num(tar,tar2) = num(tar,tar2)+(YouLabel_affection(i)==TestLabel_affection(i));
            numTotal(tar,tar2) = numTotal(tar,tar2)+1;
        case "slap"
            tar = 6;
            switch TestLabel_affection(i)
                case "calm"
                    tar2 = 1;
                case "happy"
                    tar2 = 2;
                case "sad"
                    tar2 = 3;
            end
            num(tar,tar2) = num(tar,tar2)+(YouLabel_affection(i)==TestLabel_affection(i));
            numTotal(tar,tar2) = numTotal(tar,tar2)+1;
        case "tickle"
            tar = 7;
            switch TestLabel_affection(i)
                case "calm"
                    tar2 = 1;
                case "happy"
                    tar2 = 2;
                case "sad"
                    tar2 = 3;
            end
            num(tar,tar2) = num(tar,tar2)+(YouLabel_affection(i)==TestLabel_affection(i));
            numTotal(tar,tar2) = numTotal(tar,tar2)+1;
        case "touch"
            tar = 8;
            switch TestLabel_affection(i)
                case "calm"
                    tar2 = 1;
                case "happy"
                    tar2 = 2;
                case "sad"
                    tar2 = 3;
            end
            num(tar,tar2) = num(tar,tar2)+(YouLabel_affection(i)==TestLabel_affection(i));
            numTotal(tar,tar2) = numTotal(tar,tar2)+1;
        otherwise
            disp(TestLabel_affection(i))
    end
end

for i = 1:8
    for j = 1:3
        accAction(i,j) = num(i,j)/numTotal(i,j);
    end
end

   
% parentDir = 'F:\Program\hair\数据\0411_Data\Image_process\hjl\slaping\slaping_sad';    
% allImages = imageDatastore(parentDir, ...
%     "IncludeSubfolders",true, ...
%     "LabelSource","foldernames");
% load('F:\Program\hair\数据\network\ResNet18.mat')

% YoutTest = classify(trainedGN,allImages);
% 
% TestLabel_action = [];
% YouLabel_action = [];
% TestLabel_affection = [];
% YouLabel_affection = [];
% for i = 1:length(allImages.Labels)
%     [out1, out2] = split(string(allImages.Labels(i)),'_');
%     TestLabel_action = [TestLabel_action;out1(1)];
%     TestLabel_affection = [TestLabel_affection;out1(2)];
%     [out1, out2] = split(string(YoutTest(i)),'_');
%     YouLabel_action = [YouLabel_action;out1(1)];
%     YouLabel_affection = [YouLabel_affection;out1(2)];
% end

function [numLabel_Action, numLabel_Affection] = transform(input_labels)
    Label_action = [];
    Label_affection = [];
    numLabel_Action = [];
    numLabel_Affection = [];
    for i = 1:length(input_labels)
        [out1, ~] = split(string(input_labels(i)),'_');
        Label_action = [Label_action;out1(1)];
        Label_affection = [Label_affection;out1(2)];
    end

    for i = 1:length(Label_action)
        switch Label_action(i)
            case "knock"
                num_act = 1;
                switch Label_affection(i)
                    case "calm"
                        num_aff = 1;
                    case "happy"
                        num_aff = 2;
                    case "sad"
                        num_aff = 3;
                end
            case "pat"
                num_act = 2;
                switch Label_affection(i)
                    case "calm"
                        num_aff = 1;
                    case "happy"
                        num_aff = 2;
                    case "sad"
                        num_aff = 3;
                end
            case "pet"
                num_act = 3;
                switch Label_affection(i)
                    case "calm"
                        num_aff = 1;
                    case "happy"
                        num_aff = 2;
                    case "sad"
                        num_aff = 3;
                end
            case "press"
                num_act = 4;
                switch Label_affection(i)
                    case "calm"
                        num_aff = 1;
                    case "happy"
                        num_aff = 2;
                    case "sad"
                        num_aff = 3;
                end
            case "push"
                num_act = 5;
                switch Label_affection(i)
                    case "calm"
                        num_aff = 1;
                    case "happy"
                        num_aff = 2;
                    case "sad"
                        num_aff = 3;
                end
            case "slap"
                num_act = 6;
                switch Label_affection(i)
                    case "calm"
                        num_aff = 1;
                    case "happy"
                        num_aff = 2;
                    case "sad"
                        num_aff = 3;
                end
            case "tickle"
                num_act = 7;
                switch Label_affection(i)
                    case "calm"
                        num_aff = 1;
                    case "happy"
                        num_aff = 2;
                    case "sad"
                        num_aff = 3;
                end
            case "touch"
                num_act = 8;
                switch Label_affection(i)
                    case "calm"
                        num_aff = 1;
                    case "happy"
                        num_aff = 2;
                    case "sad"
                        num_aff = 3;
                end
            otherwise
                disp(TestLabel_affection(i))
        end
        numLabel_Action = [numLabel_Action;num_act];
        numLabel_Affection = [numLabel_Affection;num_aff];
    end
    
end
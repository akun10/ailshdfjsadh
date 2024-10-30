dataOut = readall(dsVerify);
usedIdx = [];
allLabel = categorical(unique(string(dataOut(:,3))));
numEachLabel = zeros(24,1);
for i = 1:length(dataOut)
    tmpLabel = dataOut{i,3};
    tmpIdxOfLabel = find(allLabel==tmpLabel);
    if numEachLabel(tmpIdxOfLabel) < 100
        numEachLabel(tmpIdxOfLabel) = numEachLabel(tmpIdxOfLabel) + 1;
        usedIdx = [usedIdx, i];
    end
end
dataOut=dataOut(usedIdx,:);
x1 = arrayDatastore(cell2mat(dataOut(:,1)));
x2 = arrayDatastore(cell2mat(dataOut(:,2)));
x3 = arrayDatastore(dataOut(:,3));
dsTestVerify = combine(x1,x2,x3);

YoutTest = classify(net,dsTestVerify);
dataOut = readall(dsTestVerify);
VerifyLabel = categorical(string(dataOut(:,3)));

[RealAction, RealAffection] = transform(VerifyLabel);
[PredAction, PredAffection] = transform(YoutTest);
RealAll = zeros(length(RealAction),1);
PredAll = zeros(length(PredAction),1);
for indAll = 1:length(RealAction)
    RealAll(indAll) = (RealAffection(indAll)-1)*8+RealAction(indAll);
    PredAll(indAll) = (PredAffection(indAll)-1)*8+PredAction(indAll);
end
[X1,Y1,R,AUC]=perfcurve(RealAction, PredAction,1);
[X2,Y2,R,AUC]=perfcurve(RealAffection, PredAffection,1);
[X3,Y3,R,AUC]=perfcurve(RealAll, PredAll,1);

ROC = [Y3,X3];

TestLabel_action = [];
YouLabel_action = [];
TestLabel_affection = [];
YouLabel_affection = [];
for i = 1:length(VerifyLabel)
    [out1, out2] = split(string(VerifyLabel(i)),'_');
    TestLabel_action = [TestLabel_action;out1(1)];
    TestLabel_affection = [TestLabel_affection;out1(2)];
    [out1, out2] = split(string(YoutTest(i)),'_');
    YouLabel_action = [YouLabel_action;out1(1)];
    YouLabel_affection = [YouLabel_affection;out1(2)];
end

figure(1)
confusionchart(VerifyLabel,YoutTest,'Normalization','row-normalized','FontSize',20)
figure(2)
confusionchart(TestLabel_action,YouLabel_action,'Normalization','row-normalized')
figure(3)
confusionchart(TestLabel_affection,YouLabel_affection,'Normalization','row-normalized')

accuracy = mean(VerifyLabel == YoutTest);

accuracy_action = mean(TestLabel_action == YouLabel_action);
accuracy_affection = mean(TestLabel_affection == YouLabel_affection);
% figure(1)
% confusionchart(VerifyLabel,YoutTest,'Normalization','row-normalized','FontSize',20)
% figure(2)
% confusionchart(TestLabel_action,YouLabel_action,'Normalization','row-normalized')
% figure(3)
% confusionchart(TestLabel_affection,YouLabel_affection,'Normalization','row-normalized')
    
OutSoftmax=activations(net,dsTestVerify,"softmax");
rocObj = rocmetrics(VerifyLabel,OutSoftmax.',unique(VerifyLabel));
plot(rocObj,AverageROCType=["macro"],ClassNames=[])
hold on
plot(rocObj,AverageROCType=["micro"],ClassNames=[])

[FPR,TPR,Thresholds,AUC] = average(rocObj,"macro");


figure (4)
act=activations(net,dsTestVerify,"fc_1");

X = act';
% labels = unique(Dataset_Label);
labels = string(VerifyLabel);
no_dims = 2;
init_dims = 30;
perplexity = 30;
mappedX = tsne(X, NumDimensions = no_dims, Perplexity=perplexity);
gscatter(mappedX(:,1), mappedX(:,2), VerifyLabel)
% idx = randperm(size(TestData1,4),9);

num = zeros(8,3);
numTotal = zeros(8,3);
accAction = zeros(8,3);
%% Get the correlation between gestures and emotions
for i = 1:length(VerifyLabel)
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
clc;
clear;

TrainData = [];
TrainLabel = [];
VerifyData = [];
VerifyLabel = [];
TestData = [];
TestLabel = [];

train_lens = 1201;
nameData = ["knock","pat","pet","press","push","slap","tickle","touch"];

layers = [
    sequenceInputLayer(1,"Name","sequence","MinLength",train_lens)
    convolution1dLayer(100,32,"Name","conv1d_1","Padding","causal")
    reluLayer("Name","relu_1")
    layerNormalizationLayer("Name","layernorm_1")
    convolution1dLayer(100,64,"Name","conv1d_2","Padding","causal")
    reluLayer("Name","relu_2")
    layerNormalizationLayer("Name","layernorm_2")
    globalAveragePooling1dLayer("Name","gapool1d")
    fullyConnectedLayer(8,"Name","fc")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];

for i = 1:8
    F_data = [];
    
    filename = strcat("..\..\..\Dataset\data_action_recognition\",nameData(i),"\",nameData(i),"_V_sum.mat");
    temp_data = importdata(filename);
    F_data = [F_data;temp_data];
    

    [M,N] = size(F_data);
    trainNum = round(M/8*7);
    testNum = round(M/16*15);

    TrainData = [TrainData; F_data(1:trainNum,1:train_lens)];
    TrainLabel = [TrainLabel; i*ones(length(1:trainNum),1)];
    VerifyData = [VerifyData; F_data(trainNum+1:testNum,1:train_lens)];
    VerifyLabel = [VerifyLabel; i*ones(length(trainNum+1:testNum),1)];
    TestData = [TestData; F_data(1:100,1:train_lens)];
    TestLabel = [TestLabel; i*ones(length(1:100),1)];
    
end
randIndex = randperm(size(TrainData,1));
TrainData = TrainData(randIndex,:); %打乱顺序
TrainLabel = TrainLabel(randIndex,:); %打乱顺序

sequence=1;
if sequence
    TrainData = TrainData;
    train_cell = ones(size(TrainData,1),1);
    TrainData = mat2cell(TrainData,train_cell);
    VerifyData = VerifyData;
    Verify_cell = ones(size(VerifyData,1),1);
    VerifyData = mat2cell(VerifyData,Verify_cell);
    TestData = TestData;
    Test_cell = ones(size(TestData,1),1);
    TestData = mat2cell(TestData,Test_cell);
    
    TrainLabel = categorical(TrainLabel);
    VerifyLabel = categorical(VerifyLabel);
    TestLabel = categorical(TestLabel);
end


miniBatchSize = 100;

options = trainingOptions("adam", ...
    MiniBatchSize=miniBatchSize, ...
    MaxEpochs=20, ...
    SequencePaddingDirection="left", ...
    ValidationData={VerifyData,VerifyLabel}, ...
    Plots="training-progress", ...
    Verbose=0);

net = trainNetwork(TrainData,TrainLabel,layers,options);

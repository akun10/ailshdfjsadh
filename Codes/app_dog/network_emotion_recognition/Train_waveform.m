clear
close all
clc
waveform = 1;
sptrg = 0;
dataFile = './All_Data/Dataset_gesture';
SignalRoot = 'F:\Program\hair\数据\All_Data\datasetSignal\SignalNorm';
if waveform
    lgraph = importdata("./network/layergraph_gesture_0923_waveform_24.mat");
    data = load(fullfile(SignalRoot,'/waveform_Train'));
    Dataset_Data_Waveform_Train = data.Dataset_Data_Voltage_Total;
    data = load(fullfile(SignalRoot,'/charge_Train'));
    Dataset_Data_Charge_Train = data.Dataset_Data_Charge_Total;
    data = load(fullfile(SignalRoot,'/label_Train'));
    Dataset_Label_Train = data.Dataset_Label_Total;
    data = load(fullfile(SignalRoot,'/waveform_Verify'));
    Dataset_Data_Waveform_Verify = data.Dataset_Data_Voltage_Total;
    data = load(fullfile(SignalRoot,'/charge_Verify'));
    Dataset_Data_Charge_Verify = data.Dataset_Data_Charge_Total;
    data = load(fullfile(SignalRoot,'/label_Verify'));
    Dataset_Label_Verify = data.Dataset_Label_Total;
end
% l_data = size(Dataset_Data_Sptrg,1);
% l_Train = round(l_data/6*5);
% l_Verify = round(l_Train+l_data/12);
randIndex = randperm(size(Dataset_Label_Train,1));
% height = size(Dataset_Data_Sptrg,2);
% width = size(Dataset_Data_Sptrg,3);
% Dataset_Data_Sptrg_new = reshape(Dataset_Data_Sptrg,[height,width,1,l_data]);
% for h=1:height
%     for w=1:width
%         for n=1:l_data
%             Dataset_Data_Sptrg_new(h,w,1,n) = Dataset_Data_Sptrg(n,h,w);
%         end
%     end
% end
%% 打乱顺序
% Dataset_Data_Sptrg = Dataset_Data_Sptrg_new(:,:,:,randIndex); 
% Dataset_Data_Sptrm = Dataset_Data_Sptrm(randIndex,:);
Dataset_Data_Waveform_Train = Dataset_Data_Waveform_Train(randIndex,:);
Dataset_Data_Charge_Train = Dataset_Data_Charge_Train(randIndex,:);
Dataset_Label_Train = Dataset_Label_Train(randIndex,:);
% Dataset_Name = Dataset_Name(randIndex,:,:);

%% from double to arrayDataStore
TrainData1 = Dataset_Data_Waveform_Train;
TrainData2 = Dataset_Data_Charge_Train;
% TrainName = Dataset_Name(1:l_Train,:);
TrainLabel = categorical(Dataset_Label_Train);


XTrain1 = arrayDatastore(TrainData1);
XTrain2 = arrayDatastore(TrainData2);
YTrain = arrayDatastore(TrainLabel);

dsTrain = combine(XTrain2,XTrain1,YTrain);

VerifyData1 = Dataset_Data_Waveform_Verify;
VerifyData2 = Dataset_Data_Charge_Verify;
VerifyLabel = categorical(Dataset_Label_Verify);

XVerify1 = arrayDatastore(VerifyData1);
XVerify2 = arrayDatastore(VerifyData2);
YVerify = arrayDatastore(VerifyLabel);

dsVerify = combine(XVerify2,XVerify1,YVerify);


%% Training options
miniBatchSize = 10;

options = trainingOptions('sgdm', ...
    'ExecutionEnvironment','gpu', ...
    'MaxEpochs',100, ...
    'MiniBatchSize',miniBatchSize, ...
    'ValidationData',dsVerify, ...
    'Shuffle','every-epoch', ...
    'Verbose',false, ...
    'Plots','training-progress');

%% Start Train
[net,info] = trainNetwork(dsTrain,lgraph,options);

figure
plot(info.ValidationAccuracy(50:100:end))
plot(info.ValidationLoss(50:100:end))
VA = info.ValidationAccuracy(50:100:end);
VL = info.ValidationLoss(50:100:end);
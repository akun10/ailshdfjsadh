
ifclear = 1;

if ifclear
    clear
    parentDir = '..\..\..\Dataset\data_ emotion_recognition\datasetImage\ImageNorm_divided_10_train_other\Train';
    allImages = imageDatastore(parentDir, ...
        "IncludeSubfolders",true, ...
        "LabelSource","foldernames");
    % get filelist
    fileNames = {allImages.Files};
    numImages = numel(fileNames);
    allImages = shuffle(allImages);
    % [imgsTrain,imgsValidation] = splitEachLabel(allImages,0.8,"randomized");
    imgsTrain = allImages;
    disp("Number of training images: "+num2str(numel(imgsTrain.Files)))

    parentDir = '..\..\..\Dataset\data_ emotion_recognition\datasetImage\ImageNorm_divided_10_train_other\Test';
    imgsValidation = imageDatastore(parentDir, ...
        "IncludeSubfolders",true, ...
        "LabelSource","foldernames");

else
    load("All_Data\networkImageNorm89.65divided\imgsTrain.mat")
    load("All_Data\networkImageNorm89.65divided\imgsValidation.mat")
end
ifTrain = 1;

if ifTrain
    lgraph = importdata("./network/layergraph_img_0716_ResNet18_change.mat");
    numberOfLayers = numel(lgraph.Layers);
    lgraph.Layers(end-4:end)
    options = trainingOptions("sgdm", ...
    MiniBatchSize=15, ...
    MaxEpochs=10, ...
    InitialLearnRate=1e-3, ...
    ValidationData=imgsValidation, ...
    ValidationFrequency=20, ...
    LearnRateSchedule='piecewise', ...
    LearnRateDropFactor=0.3, ...
    LearnRateDropPeriod=20, ...
    Verbose=1, ...
    Plots="training-progress");
    trainedGN = trainNetwork(imgsTrain,lgraph,options);
else
    [YPred,~] = classify(trainedGN,imgsValidation);
    accuracy = mean(YPred==imgsValidation.Labels);
    disp("ResNet 18 Accuracy: "+num2str(100*accuracy)+"%")
    confusionchart(imgsValidation.Labels, YPred)
end
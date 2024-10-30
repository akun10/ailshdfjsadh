
clear
close all
clc


Dataset_Data_Voltage_Total = [];
Dataset_Data_Charge_Total = [];
Dataset_Label_Total = [];

read_F = 512; % Set used frequency range
fixed_length_sptrg_F = 128;
fixed_length_sptrg_T = 40;
fixed_length_sptrm = 256;
fixed_length_charge = 100;
fixed_length_V = 1000;
sampleRate = 5000;
dataFile = './All_Data/';
NewDir = '/saveData/';

save_train_signal = 1;
if save_train_signal
    experimentorSet = ["user1","user2","user3","user4","user5","user7","user8","user9","user10","user11","user12","user13"];
else
    experimentorSet = "user6";
end


Gesture = ["peting","press","push","pating","slap","slaping","touch","tickle","tickling","knock"];
scatterSize = 30;
name_num = 0;
ii = 1;
imageRoot = '..\..\..\Dataset\data_ emotion_recognition\datasetImage\ImageNorm_Force_30_only';
SignalRoot = '..\..\..\Dataset\data_ emotion_recognition\datasetSignal\SignalNorm';
experimentNum = 0;
maxData = zeros(6,10,3,10000);
for experimentorName = experimentorSet
    experimentorName
    experimentNum = experimentNum + 1;
    gesture_num = 0;
    name_num = name_num + 1;
    co_gest = [];
for gestVar = Gesture
    gestVar
    gesture_num = gesture_num + 1;
    if strcmp(gestVar, "slap") || strcmp(gestVar, "tickle")
        gesture_num = gesture_num - 1;
    end
    data_std_time_show = [];
    for video_num = 1:9
        imLength = 1;
        saveDataDir = [dataFile,char(experimentorName),NewDir,char(gestVar),'_',num2str(video_num),'_'];
        if ~exist([saveDataDir,'charge/1.mat'],'file')
          continue;
        end
    
        filesname = saveDataDir;
        files = dir([filesname,'charge/']);
        numFiles = length(files)-2;
        data_label = [];
        % data_va = [];
        data_std_time = [];
        data_charge = [];
        data_waveform = [];
        % data_sptrm = [];
        % data_sptrg = [];
        for index = 1:numFiles
            %% read data
            file_name = [filesname,'charge/',num2str(index),'.mat'];
            load(file_name);
            V_std = std(V_Seg);
            V_time = length(V_Seg)/5000;
            indexT = find(abs(V_Seg)>0.005 );
            indexROI = [indexT(1),indexT(end)];
            %plot(V_Seg);
            %hold on;
            %scatter(indexROI,0,30,"red","filled")
            V_new1 = [V_Seg(indexROI(2):end),V_Seg(1:indexROI(2))];
            V_new2 = [V_Seg(indexROI(1):end),V_Seg(1:indexROI(1))];
            %hold off;
            % get inputs
            
            %% set label
            % label = string([char(gestVar),'_',num2str(video_num)]);
            if gestVar == "tickling"
                saveName = "tickle";
            elseif extract(gestVar,"ing") == "ing"
                saveName = erase(gestVar,"ing");
            else
                saveName = gestVar;
            end
            if video_num < 4
                moodNum = 1;
                label = string([char(saveName),'_happy']);
            elseif video_num < 7
                moodNum = 2;
                label = string([char(saveName),'_calm']);
            else
                moodNum = 3;
                label = string([char(saveName),'_sad']);
            end
            tmp = [V_std,V_time];

            [o2,o3,maxIm] = saveImageSignal(V_Seg,label,fullfile(imageRoot,char(experimentorName)));
            Dataset_Data_Voltage_Total = [Dataset_Data_Voltage_Total;o2];
            Dataset_Data_Charge_Total = [Dataset_Data_Charge_Total;o3];
            Dataset_Label_Total = [Dataset_Label_Total,label];
            maxData(experimentNum,gesture_num,moodNum,imLength)=maxIm;
            imLength = imLength + 1;
            ii = ii + 1;
            if numFiles < 100
                [o2,o3,maxIm] = saveImageSignal(V_new1,label,fullfile(imageRoot,char(experimentorName)));
                Dataset_Data_Voltage_Total = [Dataset_Data_Voltage_Total;o2];
                Dataset_Data_Charge_Total = [Dataset_Data_Charge_Total;o3];
                Dataset_Label_Total = [Dataset_Label_Total,label];
                maxData(experimentNum,gesture_num,moodNum,imLength)=maxIm;
                imLength = imLength + 1;
                ii = ii + 1;
                if numFiles < 50
                    [o2,o3,maxIm] = saveImageSignal(V_new2,label,fullfile(imageRoot,char(experimentorName)));
                    Dataset_Data_Voltage_Total = [Dataset_Data_Voltage_Total;o2];
                    Dataset_Data_Charge_Total = [Dataset_Data_Charge_Total;o3];
                    Dataset_Label_Total = [Dataset_Label_Total,label];
                    maxData(experimentNum,gesture_num,moodNum,imLength)=maxIm;
                    imLength = imLength + 1;
                    ii = ii + 1;
                end
            end

        end
    end
end
end
Dataset_Label_Total = Dataset_Label_Total.';
if save_train_signal
    save(fullfile(SignalRoot,'/waveform_Train'),"Dataset_Data_Voltage_Total")
    save(fullfile(SignalRoot,'/charge_Train'),"Dataset_Data_Charge_Total")
    save(fullfile(SignalRoot,'/label_Train'),"Dataset_Label_Total")
else
    save(fullfile(SignalRoot,'/waveform_Verify'),"Dataset_Data_Voltage_Total")
    save(fullfile(SignalRoot,'/charge_Verify'),"Dataset_Data_Charge_Total")
    save(fullfile(SignalRoot,'/label_Verify'),"Dataset_Label_Total")
end

%% save Image
function [outV,outQ,maxIm] = saveImageSignal(V_Seg,label,imageRoot)
    sampleRate = 5000;
    fixed_length_charge = 100;
    fixed_length_V = 1000;
    
    [T,F,Pout,FV1_ROI,Pout2,Xout,Qout,V_Seg] = saveFileFunc(V_Seg, sampleRate);
    outQ=interp1(1:length(Qout), Qout(:,1), 0:(length(Qout))/(fixed_length_charge-1):length(Qout),'spline');
    outV=interp1(1:length(V_Seg), V_Seg(1,:), 0:(length(V_Seg))/(fixed_length_V-1):length(V_Seg),'spline');
            
    maxIm = 0;
    if 0 % if save Image
        thr=0.05;gap = 0;
        % thr_vaild = 0.05;
        % V_Seg_valid_index = find(V_Seg>thr_vaild);
        % V_Seg_valid = V_Seg(V_Seg_valid_index(1):V_Seg_valid_index(end));
        [peaks_data_right,peaks_index_right] = findpeaks(V_Seg);
        % [peaks_data_right,peaks_index_right] = findpeaks(V_seg);
        peaks_right = find(peaks_data_right>thr);
        vaild_peak = [];
        for kk = 1:length(peaks_right)-1
            if peaks_index_right(peaks_right(kk+1))-peaks_index_right(peaks_right(kk))>gap
                vaild_peak = [vaild_peak,kk];
            end
        end
        peaks_right = peaks_right(vaild_peak);
        time_slide = length(V_Seg)/sampleRate;
        cnt_peak_list = length(peaks_right);
        fre = cnt_peak_list./time_slide;
    
        fb = cwtfilterbank(SignalLength=length(V_Seg), ...
            SamplingFrequency=sampleRate, ...
            VoicesPerOctave=12);
        cfs = abs(fb.wt(V_Seg));
    
        X_Q=1:length(Qout);
        Qout = Qout-(Qout(end)-Qout(1))/length(Qout).*X_Q';
        Q_max = max(Qout);  
    
        [m_cfs,n_cfs]=size(cfs);
        cfs_save=zeros(m_cfs+30,n_cfs);
        % 按1000数量进行分段频率计算
        num_thousand = floor(length(V_Seg)/1000);
        fre_sec = zeros(num_thousand,1);
        tmp_num = 0;
    
        % for i = 1:num_thousand
        %     b=find(peaks_index_right(peaks_right)<=i*1000);
        %     fre_sec(i) = (length(b) - tmp_num)./1000.*sampleRate;
        %     tmp_num = length(b);
        %     cfs_save(1:10,(i-1)*1000+1:i*1000) = fre_sec(i)/2000;
        %     cfs_save(11:10+m_cfs,1:n_cfs)=cfs;
        % end
        % cfs_save(41:80,:) = Q_max/1000;
        cfs_save(1:30,:) = Q_max/1000; %fre_sec(i)/2000;
        cfs_save(31:30+m_cfs,1:n_cfs)=cfs;
    
        im = ind2rgb(round(rescale(cfs_save,0,255)),jet(128));
        % cfs(:,:) = 
        % im = ind2rgb(round((cfs_save*255/0.1)),jet(128));
        im = imresize(im,[224 224]);
        maxIm = max(max(cfs_save));
        imgLoc = fullfile(imageRoot,char(label));
        if ~exist(imgLoc,'dir')
            mkdir(imgLoc);
        end
        files = dir(imgLoc);
        numFiles = length(files)-2;
        imFileName = char(label)+"_"+num2str(numFiles+1)+".jpg";
        imwrite(imresize(im,[224 224]),fullfile(imgLoc,imFileName));
    end
end

function [T,F,Pout,FV1_ROI,Pout2,Xout,Qout,V_Seg] = saveFileFunc(V_read, sampleRate)
    %Set spectrum parameters
    frequencyLimits = [0 1000]; % Hz
    timeResolution = 0.1; % 秒
    overlapPercent = 50;

    % Obtain the segmented interval charge signal
    Q_read = zeros(length(V_read),1);
    for i = 2:length(V_read)
        Q_read(i) = Q_read(i-1)+V_read(i);
    end
    for i = 2:length(V_read)
        Q_read(i) = Q_read(i) - Q_read(end)./length(V_read)*i;
    end

    % Set the frequency interval time value
    timeValues_read = (0:length(V_read)-1).'/sampleRate;
    
    % Draw time-frequency diagram
    [P1,F,T] = pspectrum(V_read,timeValues_read, ...
        'spectrogram', ...
        'FrequencyLimits',frequencyLimits, ...
        'TimeResolution',timeResolution, ...
        'OverlapPercent',overlapPercent);
    
    % Draw FFT spectrum
    [PV1_ROI, FV1_ROI] = pspectrum(V_read,sampleRate, ...
        'FrequencyLimits',frequencyLimits);
    %subplot(4,1,1)
    %surface(T,F,10*log10(P1))
    %shading interp
    %colormap(jet)
    %colorbar
    %clim([-100 -40])

    % Save time-frequency diagram
    Pout = 10*log10(P1);
    %subplot(4,1,2)
    %plot(FV1_ROI, 10*log10(PV1_ROI))
    %ylim([-100 -20])

    % Save FFT spectrum
    Pout2 = 10*log10(PV1_ROI);
    
    % Draw charge
    % subplot(4,1,3)
    %plot(Q_read-min(Q_read))
    
    % Draw voltage
    Xout = (1:length(V_read)) ./ 5000;
    %subplot(4,1,4)
    %plot(Xout,V_read)
    % Save charge
    Qout = Q_read-min(Q_read);
    V_Seg = V_read;

end

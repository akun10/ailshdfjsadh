clc;
clear;
close all;
%The size of the isoline
M = 16;

x = linspace(1,M,M);
y = linspace(1,M,M);
[X, Y] = meshgrid(x,y);
%Raw data with time
file_V1 = readmatrix('.\mat_new\rawdata\SDS6034_H10_Pro_CSV_C1_1.csv');
file_V2 = readmatrix('.\mat_new\rawdata\SDS6034_H10_Pro_CSV_C2_1.csv');
file_V3 = readmatrix('.\mat_new\rawdata\SDS6034_H10_Pro_CSV_C3_1.csv');
file_V4 = readmatrix('.\mat_new\rawdata\SDS6034_H10_Pro_CSV_C4_1.csv');
%Raw data
data_V1 = file_V1(14:end,2);
data_V2 = file_V2(14:end,2);
data_V3 = file_V3(14:end,2);
data_V4 = file_V4(14:end,2);
%simple rate
fs = 1/(file_V1(16,1)-file_V1(15,1));
%lowpass filter
[h,b] = lp_30_50;
data_lp_V1 = filtfilt(b,1,data_V1);
data_lp_V2 = filtfilt(b,1,data_V2);
data_lp_V3 = filtfilt(b,1,data_V3);
data_lp_V4 = filtfilt(b,1,data_V4);
%Filtered data
data_lp_V1 = data_lp_V1-mean(data_lp_V1(1:1000));
data_lp_V2 = data_lp_V2-mean(data_lp_V2(1:1000));
data_lp_V3 = data_lp_V3-mean(data_lp_V3(1:1000));
data_lp_V4 = data_lp_V4-mean(data_lp_V4(1:1000));

%Data segmentation
thr = 0.1;
thr_sep = 5000;
data_sum = data_lp_V1+data_lp_V2+data_lp_V3+data_lp_V4;
[data_bpoint_1,data_bpoint_2] = sep_data(data_sum,thr,thr_sep);
%plot the results of the segmentation
figure(7)
plot(data_sum)
hold on
scatter(data_bpoint_1,0.1,'filled')
scatter(data_bpoint_2,0.1,'filled')
%the result of isoline
Mat12_1234_1 = zeros(M);
Mat14_1234_1 = zeros(M);
Mat12_1234 = zeros(M);
Mat14_1234 = zeros(M);

%Processing data

for i = 1:M   %Select a row
    data_vaild_1 = data_lp_V1(data_bpoint_2(i):data_bpoint_1(i));
    data_vaild_2 = data_lp_V2(data_bpoint_2(i):data_bpoint_1(i));
    data_vaild_3 = data_lp_V3(data_bpoint_2(i):data_bpoint_1(i));
    data_vaild_4 = data_lp_V4(data_bpoint_2(i):data_bpoint_1(i));
    data_total = data_vaild_1+data_vaild_2+data_vaild_3+data_vaild_4;
    [data_vaild_bpoint_1,data_vaild_bpoint_2] = sep_data(data_total,thr,2000);
    for j = 1:M %Select a point
        data_vaild_sep_1 = data_vaild_1(data_vaild_bpoint_2(j):data_vaild_bpoint_1(j));
        data_vaild_sep_2 = data_vaild_2(data_vaild_bpoint_2(j):data_vaild_bpoint_1(j));
        data_vaild_sep_3 = data_vaild_3(data_vaild_bpoint_2(j):data_vaild_bpoint_1(j));
        data_vaild_sep_4 = data_vaild_4(data_vaild_bpoint_2(j):data_vaild_bpoint_1(j));
        data_vaild_sep_total = data_vaild_sep_1+data_vaild_sep_2+data_vaild_sep_3+data_vaild_sep_4;
        %find peaks
        [peaks_data_1,peaks_index_1] = findpeaks(data_vaild_sep_1);
        [peaks_data_2,peaks_index_2] = findpeaks(data_vaild_sep_2);
        [peaks_data_3,peaks_index_3] = findpeaks(data_vaild_sep_3);
        [peaks_data_4,peaks_index_4] = findpeaks(data_vaild_sep_4);
        [peaks_data_right,peaks_index_right] = findpeaks(data_vaild_sep_total,"MinPeakProminence",thr);
        %show the row data with peaks
        figure(1)
        plot(data_vaild_sep_1)
        hold on
        plot(data_vaild_sep_2)
        plot(data_vaild_sep_3)
        plot(data_vaild_sep_4)
        maxiP = max(max([peaks_data_1;peaks_data_2;peaks_data_3;peaks_data_4]));
        ylim([0,maxiP])

        %get valid peaks
        peaks_right = find(peaks_data_right>thr);
        sco_num =0;
        peaks_1 = right_peak(peaks_right,peaks_index_right,peaks_index_1,peaks_data_1,sco_num);
        peaks_2 = right_peak(peaks_right,peaks_index_right,peaks_index_2,peaks_data_2,sco_num);
        peaks_4 = right_peak(peaks_right,peaks_index_right,peaks_index_4,peaks_data_4,sco_num);
        peaks_3 = right_peak(peaks_right,peaks_index_right,peaks_index_3,peaks_data_3,sco_num);
        
        peaks_1 = peaks_1(2:end-1);
        peaks_2 = peaks_2(2:end-1);
        peaks_3 = peaks_3(2:end-1);
        peaks_4 = peaks_4(2:end-1);
        V1 = peaks_data_1(peaks_1);
        V2 = peaks_data_2(peaks_2);
        V3 = peaks_data_3(peaks_3);
        V4 = peaks_data_4(peaks_4);
        %calculate ratios
        V1V2_V1V2V3V4_1=(1./V1+1./V2)./(1./V1+1./V2+1./V3+1./V4);
        V1V4_V1V2V3V4_1=(1./V1+1./V4)./(1./V1+1./V2+1./V3+1./V4);
        V1V2_V1V2V3V4 = (V1 + V2)./(V1+V2+V3+V4);
        V1V4_V1V2V3V4 = (V1 + V4)./(V1+V2+V3+V4);
        %Select the ratio that occurs the most times
        acur = 100;
        V1V2_V1V2V3V4_round = round(V1V2_V1V2V3V4*acur)/acur;
        V1V4_V1V2V3V4_round  = round(V1V4_V1V2V3V4*acur)/acur;
        V1V2_V1V2V3V4_1_round  = round(V1V2_V1V2V3V4_1*acur)/acur;
        V1V4_V1V2V3V4_1_round  = round(V1V4_V1V2V3V4_1*acur)/acur;
        
        maxIndices_12 = findindex(V1V2_V1V2V3V4_round);
        maxIndices_14 = findindex(V1V4_V1V2V3V4_round);
        maxIndices_12_1 = findindex(V1V2_V1V2V3V4_1_round);
        maxIndices_14_1 = findindex(V1V4_V1V2V3V4_1_round);
        %averaging
        Mat12_1234_1(i,j) = mean(V1V2_V1V2V3V4_1(maxIndices_12_1));
        Mat14_1234_1(i,j) = mean(V1V4_V1V2V3V4_1(maxIndices_14_1));
        Mat12_1234(i,j) = mean(V1V2_V1V2V3V4(maxIndices_12));
        Mat14_1234(i,j) = mean(V1V4_V1V2V3V4(maxIndices_14));
        %plot row data of every point
        scatter(peaks_index_1(peaks_1),peaks_data_1(peaks_1))
        text(peaks_index_1(peaks_1),peaks_data_1(peaks_1),num2str(V1V2_V1V2V3V4))
        scatter(peaks_index_2(peaks_2),peaks_data_2(peaks_2),'r')
        scatter(peaks_index_3(peaks_3),peaks_data_3(peaks_3),'g')
        scatter(peaks_index_4(peaks_4),peaks_data_4(peaks_4),'d')
        ylim([0,maxiP])
        hold off
    end
   
end

figure(5)
contour(X,Y,Mat12_1234,50)
figure(6)
contour(X,Y,Mat14_1234,50)
figure(3)
contour(X,Y,Mat12_1234_1,50)
figure(4)
contour(X,Y,Mat14_1234_1,50)
% save data
% save('./12_1234.mat',"Mat12_1234");
% save('./14_1234.mat',"Mat14_1234");
% save('./12_1234_1.mat',"Mat12_1234_1");
% save('./14_1234_1.mat',"Mat14_1234_1");

function peaks_num = right_peak(peaks_right,peaks_index_right,peaks_index_wrong,peaks_data_wrong,scope_num)
    peaks_num = [];
    for k = 1:length(peaks_right)

        right_num = peaks_index_right(peaks_right(k));
        
        sub_index = abs(peaks_index_wrong-right_num);
        [~,min_num] = min(sub_index);
        if min_num-scope_num>0
            start_peak = min_num-scope_num;
        else
            start_peak = 1;
        end
        if min_num+scope_num<=length(peaks_data_wrong)
            end_peak = min_num+scope_num;
        else
            end_peak = length(peaks_data_wrong);
        end
        
        if min_num+scope_num>length(peaks_data_wrong)   
            [~,max_num] = max(peaks_data_wrong(start_peak:end));
            peaks_num(k) = min_num;
        elseif min_num-scope_num<1
            [~,max_num] = max(peaks_data_wrong(1:end_peak));
            peaks_num(k) = min_num;
        else
            [~,max_num] = max(peaks_data_wrong(start_peak:end_peak));
            peaks_num(k) = max_num+min_num-scope_num-1;
        end
                     
    end
end

function [a_point,b_point] = sep_data(data,thr,arange_num)
    data_thr_index = find(data>=thr);
    j = 0;
    for i = 1:length(data_thr_index)-1
        if data_thr_index(i+1) - data_thr_index(i) >= arange_num
            j = j+1;
            a_point(j) = data_thr_index(i);
            b_point(j+1) = data_thr_index(i+1);
        end
    end
    a_point(j+1) = data_thr_index(end-2);
    b_point(1) = data_thr_index(3);
    a_point = a_point+1;
    b_point = b_point-1;

end

function maxIndices = findindex(arr)
    % 初始化变量以保存结果
    maxCount = 0;  % 最大重复次数
    maxIndices = [];  % 最大重复次数的元素索引
    
    % 使用循环遍历数组
    for i = 1:length(arr)
        % 获取当前元素
        currentElement = arr(i);
        
        % 计算当前元素在数组中的重复次数
        count = sum(arr == currentElement);
        
        % 检查是否当前元素的重复次数大于最大重复次数
        if count > maxCount
            maxCount = count;  % 更新最大重复次数
            maxIndices = i;    % 重置最大重复次数的元素索引
        elseif count == maxCount
            maxIndices = [maxIndices, i];  % 添加当前索引到最大重复次数的元素索引
        end
    end
end

% 对峰进行筛选，删去高度低于前一峰且位置于前一峰的峰宽内的峰
function [spike_index_new,p_new] = screenPeak(v,spike_index,w,p,lo2)
    spike_index_new = [];
    p_new = [];
    tmp = 1;
    spike_index_new = [spike_index_new, spike_index(1)];
    p_new = [p_new, p(1)];

    for i = 2:length(spike_index)
        % 当前峰小于上个峰的峰值 且 峰的位置在前个峰的范围内
        if v(spike_index(i)) < v(spike_index(tmp)) && ...
                spike_index(tmp) + w(tmp)/1.2 > spike_index(i) && w(tmp) < 500 || ...
            v(spike_index(i)) - 1*p(i) > lo2(spike_index(i)) + 0.2
        else
            spike_index_new = [spike_index_new, spike_index(i)];
            p_new = [p_new, p(i)];
            tmp = i;
        end
    end
    % disp(length(spike_index))
    % disp(length(spike_index_new))
end

   

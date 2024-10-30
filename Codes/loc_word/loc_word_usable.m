clc;
clear;
close all;

thr = 0.2;
posi = 0;
word_x = [];
word_y = [];
min_distance = 10; 


M=16;

x = linspace(1,M,M);
y = linspace(1,M,M);
[X, Y] = meshgrid(x,y);

% Import the isoline network
Mat1 = importdata('./equline/12_1234.mat');
Mat2 = importdata('./equline/14_1234.mat');

filename = '.\data\line_used_double';
% filename = '.\data\s1';

% Read acquisition data
vot_data_s_1 = readmatrix([filename,'\SDS6034_H10_Pro_CSV_C1_1.csv']);
vot_data_s_2 = readmatrix([filename,'\SDS6034_H10_Pro_CSV_C2_1.csv']);
vot_data_s_3 = readmatrix([filename,'\SDS6034_H10_Pro_CSV_C3_1.csv']);
vot_data_s_4 = readmatrix([filename,'\SDS6034_H10_Pro_CSV_C4_1.csv']);
fs = 1/(vot_data_s_1(16,1)-vot_data_s_1(15,1));

V1 = vot_data_s_1(14:end,2);
V2 = vot_data_s_2(14:end,2);
V3 = vot_data_s_3(14:end,2);
V4 = vot_data_s_4(14:end,2);

V1 = vot_data_s_1(14:end-100000,2);
V2 = vot_data_s_2(14:end-100000,2);
V3 = vot_data_s_3(14:end-100000,2);
V4 = vot_data_s_4(14:end-100000,2);


data_V1 = V1-mean(V1(1:1000));
data_V2 = V2-mean(V2(1:1000));
data_V3 = V3-mean(V3(1:1000));
data_V4 = V4-mean(V4(1:1000));

[Hd,b] = bF_1_usable;
[data_V1,zf] = filter(b,1,data_V1);
[data_V2,zf] = filter(b,1,data_V2,zf);
[data_V3,zf] = filter(b,1,data_V3,zf);
[data_V4,zf] = filter(b,1,data_V4,zf);

data_total = data_V1+data_V2+data_V3+data_V4;

% Find the waveform peak and corresponding position for each channel
[peaks_data_1,peaks_index_1] = findpeaks(data_V1);
[peaks_data_2,peaks_index_2] = findpeaks(data_V2);
[peaks_data_3,peaks_index_3] = findpeaks(data_V3);
[peaks_data_4,peaks_index_4] = findpeaks(data_V4);
[peaks_data_total,peaks_index_total] = findpeaks(data_total);

% Filter for peaks high enough
thr_index = find(peaks_data_total>thr);
peaks_right = peak_find(thr_index,peaks_data_total(thr_index),min_distance);

peaks_index_right = peaks_index_total;

peaks_1 = right_peak(peaks_right,peaks_index_right,peaks_index_1,peaks_data_1,min_distance);
peaks_2 = right_peak(peaks_right,peaks_index_right,peaks_index_2,peaks_data_2,min_distance);
peaks_3 = right_peak(peaks_right,peaks_index_right,peaks_index_3,peaks_data_3,min_distance);
peaks_4 = right_peak(peaks_right,peaks_index_right,peaks_index_4,peaks_data_4,min_distance);

DVM1 = peaks_data_1(peaks_1);
DVM2 = peaks_data_2(peaks_2);
DVM3 = peaks_data_3(peaks_3);
DVM4 = peaks_data_4(peaks_4);



Data1 = (DVM1+DVM2)./(DVM1+DVM2+DVM3+DVM4);
Data2 = (DVM1+DVM4)./(DVM1+DVM2+DVM3+DVM4);



pos_one_s = [Data1(diff(Data1)~=0);Data1(end)];
pos_two_s = [Data2(diff(Data2)~=0);Data2(end)];
Ratio1 = pos_one_s;
Ratio2 = pos_two_s;


%Calculate contours intersections
for i = 1:length(pos_two_s)
    %Find the contour line corresponding to a particular value c1：(x,y) Coordinate set
    figure(4)
    [c1,h_s1]=contour(X,Y,Mat1,[pos_one_s(i),pos_one_s(i)]);
    hold on
    [c2,h_s2]=contour(X,Y,Mat2,[pos_two_s(i),pos_two_s(i)]);
    p = intp2(c1,c2);
    disp(p)

    if ~isempty(p) %If the intersection exists
        word_x(i) = p(1,1);
        word_y(i) = p(1,2);
    else %If the intersection doesn't exist
        word_x(i) = 0;
        word_y(i) = 0;
        disp('no point at')
        disp(pos_one_s(i))
        disp(pos_two_s(i))
    end
end

le = length(word_x);
data_x = 1:le;
figure(1)
sz = 50;
c = linspace(0,100,length(word_x));
scatter(word_x,word_y,sz,c,'filled');
text(word_x,word_y,num2str(data_x.'))
set(gca,'linewidth',2);
colormap((jet))
xlim([0,M])
ylim([0,M])

figure(2)
plot(data_total)
hold on
scatter(peaks_index_right(peaks_right),peaks_data_total(peaks_right),sz,c,'filled')
text(peaks_index_right(peaks_right),peaks_data_total(peaks_right),num2str(data_x.'))




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


function peaks = peak_find(peaks_index,peaks_data,min_distance)
    last_peak = 0;
    peak_num = 1;
    for j = 1:length(peaks_index)
        if last_peak ==0
            last_peak = j;
        elseif peaks_index(j)-peaks_index(last_peak)>min_distance % If the distance between peaks is large enough
            peaks(peak_num) = peaks_index(last_peak); %Record the last peak
            peak_num = peak_num+1;
            last_peak = j;
        else
            if peaks_data(j)>peaks_data(last_peak)% If the new peak amplitude is larger
                last_peak = j; %Discard the previous peak

            end
                   
        end
    end
    peaks(peak_num) = peaks_index(last_peak); %The last peak is also recorded
end




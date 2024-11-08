clc;
clear;
close all

thickness=[0.2,0.25,0.3];
speed = [1,5,8,10,30,50,80,100,150,200,300];
space = [0,0.5,1,2,3];
maxy = 0;
for thick = 1:3%:3
for i = 1:length(space)
    %Read the data and view the waveform at different speeds
    spike_speed = zeros(length(speed),1);
    spike_speed_all = zeros(length(speed),30);
    spike_speed_all_box = [];
    spike_mean = [];
    spike_std = [];
    g = [];
    g2 = [];
    for j = 1:length(speed)
        filename = strcat("./0626/diff_high_",string(thickness(thick)),"_multi_finger/",string(space(i)),...
            '_',string(speed(j)),"/SDS6034_H10_Pro_CSV_C1_1.csv");     
        % fileNameDir = strcat("./diff_high_0.2_multi_finger/",string(space(i)),...
        %     '_',string(speed(j)));
        % fileNameNum = size(dir(fileNameDir),1)-2;
        % if fileNameNum > 1
        %     disp(filename)
        %     waitforbuttonpress
        % end
        file = readmatrix(filename);
        data_t1 = file(3:end,1);
        data_t1 = data_t1 - data_t1(1);
        data_V1 = file(3:end,2);
        for endY = 1:length(data_V1)-1
            if data_V1(endY+1) < 1e4
            else
                break;
            end
        end
        data_t1 = data_t1(1:endY);
        data_V1 = data_V1(1:endY);
        fs=1/(data_t1(2)-data_t1(1));
        % waitforbuttonpress
        Q1 = zeros(length(data_V1),1);
        mean_V1 = mean(data_V1);
        Q1(1) = data_V1(1)-mean_V1;
        for q = 2:length(data_V1)
            Q1(q) = Q1(q-1)+data_V1(q)-mean_V1;
        end
        Q_start_thres = 1000;
        Q_end_thres = 500;
        Q1 = smooth(Q1, fs/j);
        QProminence = (max(Q1)-min(Q1))/8;
        [~,indexPeak] = findpeaks(-Q1, "MinPeakDistance",fs/j, MinPeakProminence=QProminence);
        if length(indexPeak) < 13 % There are some cases where the charge changes violently and need to be dealt with separately
            [~,indexPeak] = findpeaks(-data_V1, "MinPeakDistance",fs*4, MinPeakHeight=0.5);
            indexPeak = indexPeak+20000;
            if length(indexPeak) < 13
                [~,indexPeak] = findpeaks(data_V1, "MinPeakDistance",10000, MinPeakHeight=0.1);
                indexPeak(1) = [];
                indexPeak = indexPeak - 5000;
                indexPeak = indexPeak(1:5);
                Q_start_thres = 0;
                Q_end_thres = 1000;
            end
        end
        
        figure(1)
        plot(data_t1,Q1)
        hold on
        scatter(data_t1(indexPeak),0)
        hold off
        
        spike_num = zeros(length(indexPeak)-1,1);
        spike_fre = zeros(length(indexPeak)-1,1);
        spike_time = zeros(length(indexPeak)-1,1);
        for k = 2:length(indexPeak)
            t = data_t1(indexPeak(k-1):indexPeak(k));
            t = t - t(1);
            spike_time(k-1) = length(t);
            v = data_V1(indexPeak(k-1):indexPeak(k));
            Q2 = zeros(length(v),1);
            mean_V2 = mean(v);
            Q2(1) = v(1)-mean_V2;
            for q = 2:length(v)
                Q2(q) = Q2(q-1)+v(q)-mean_V2;
            end
            % Find press interval
            % [vQ1,indexQ,wq,pq] = findpeaks(Q2, "MinPeakProminence",0.2,'Annotate','extents');
            % Q_start_ind = find(pq>max(Q2)/2);
            % Q_start = indexQ(Q_start_ind+1);%max(Q2)/5*1;
            % 
            % [vQ2,indexQ,wq,pq] = findpeaks(-smooth(v,100), "MinPeakProminence",0.2,'Annotate','extents');
            % Q_end_ind = find(wq>500);
            % if ~isempty(Q_end_ind)
            %     Q_end = indexQ(Q_end_ind(end)-1);
            % else
            %     Q_thres = max(Q2)/3*2;
            %     [val,~]=find(Q2 > Q_thres);
            %     Q_end = val(end);
            % end
            
            Q_thres = max(Q2)/3*2;
            [val,~]=find(Q2 > max(Q2)/3*2);
            Q_start = val(1)+Q_start_thres;
            [val,~]=find(Q2 > max(Q2)/3*1);
            Q_end = val(end)-Q_end_thres;
            
            % figure(5)
            % plot(Q2)
            % hold on
            % scatter(Q_start,1000)
            % scatter(Q_end,1000)
            % plot(v*500)
            % hold off

            % Q_start = val(1);
            l_se = 0;
            [up2,lo2] = envelope(v,200,'peak');

            t2 = t(Q_start+l_se/8:Q_end-l_se/8);
            v2 = v(Q_start+l_se/8:Q_end-l_se/8);
            lo2 = lo2(Q_start+l_se/8:Q_end-l_se/8);
            % [p,s,mu] = polyfit((1:numel(v))',v,10);
            % f_y = polyval(p,(1:numel(v))',[],mu);
            % v = v - f_y;

            [~,spike_index,w,p] = findpeaks(v2, "MinPeakProminence",0.2,"MinPeakDistance",20);
            
            % The peaks are screened, and the peaks that are lower in height and within the peak width of the previous peak are deleted
            [spike_index_new,p_new] = screenPeak(v2,spike_index,w,p,lo2);

            % waitforbuttonpress
            % while ~strcmpi(get(gcf,'CurrentCharacter'),'q') % 检测是否按下了 'q' 键
            %     pause(1)
            % end

            spike_num(k-1) = length(spike_index_new);
            spike_fre(k-1) = length(spike_index_new)/(t2(spike_index_new(end))-t2(spike_index_new(1)));
            
            
            v_p = ones(length(spike_index_new),1);
            for i_p = 1:length(spike_index_new)
                v_p(i_p) = v2(spike_index_new(i_p))-1*p_new(i_p);
            end   
            for i_p = 1:length(spike_index)
                v_p(i_p) = v2(spike_index(i_p))-1*p(i_p);
            end

        end
        spike_speed(j) = mean(spike_fre);
        spike_speed_all(j,1:length(spike_fre)) = spike_fre;
        figure(4)
        subplot(2,1,1)
        bar(spike_fre)
        subplot(2,1,2)
        bar(spike_time)
        drawnow
        spike_speed_all_box = [spike_speed_all_box; spike_fre];
        g = [g; repmat({string(speed(j))},length(spike_fre),1)];
        g2 = [g2; repmat(speed(j),length(spike_fre),1)];
        spike_mean = [spike_mean; mean(spike_fre)];
        spike_std = [spike_std; std(spike_fre)];
    end
    figure(3)
    subplot(3,5,(thick-1) * 5 + i);
    boxplot(spike_speed_all_box, g);
    % save(strcat(string(thickness(thick)),string(space(i)),...
    %         '_data.mat'),"spike_speed_all_box");
    % save(strcat(string(thickness(thick)),string(space(i)),...
    %         '_class.mat'),"g2");
    % save(strcat(string(thickness(thick)),"_",string(space(i)),...
    %         '_mean.mat'),"spike_mean");
    % save(strcat(string(thickness(thick)),"_",string(space(i)),...
    %         '_std.mat'),"spike_std");
    maxy = max(maxy,max(max(spike_speed_all)));
    maxy = min(maxy,500);
    for num_i = 1:i
        subplot(3,5,(thick-1) * 5 + num_i);
        ylim([0,maxy]);
    end
    
end
end


% The peaks are screened, and the peaks that are lower in height and within the peak width of the previous peak are deleted
function [spike_index_new,p_new] = screenPeak(v,spike_index,w,p,lo2)
    spike_index_new = [];
    p_new = [];
    tmp = 1;
    spike_index_new = [spike_index_new, spike_index(1)];
    p_new = [p_new, p(1)];

    for i = 2:length(spike_index)
        % The current peak is smaller than the peak of the previous peak and the position of the peak is within the range of the previous peak
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
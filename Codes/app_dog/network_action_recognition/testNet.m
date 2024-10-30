clc
clear
load("Result_net.mat")
load("testdata.mat")
load("testlabel.mat")
miniBatchSize = 20;
randIndex = randperm(size(TestData,1));
TestData = TestData(randIndex,:); %打乱顺序
TestLabel = TestLabel(randIndex,:); %打乱顺序
YPred = classify(net,TestData,'MiniBatchSize',miniBatchSize);
acc = mean(YPred == TestLabel);
confusionMat = zeros(8,8);
i = 0;
numTest = zeros(8,1);
for a = TestLabel.'
    i = i + 1;
    numTest(double(a)) = numTest(double(a))+1;
    if double(string(YPred(i,1))) > 0
        tmp = double(string(YPred(i,1)));
    end
    if double(string(a)) > 0
        tmp2 = double(string(a));
    end
    confusionMat(tmp2,tmp) = confusionMat(tmp2,tmp)+1;
end
for i = 1:8
    confusionMat(i,:) = confusionMat(i,:)./numTest(i)*100; % i的位置可能搞反了
end
% 标签
%label = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','Blank'};
label = ["knock","pat","pet","press","push","slap","tickle","touch"];
% 混淆矩阵主题颜色
% 可通过各种拾色器获得rgb色值
maxcolor = [191,54,12]; % 最大值颜色
mincolor = [255,255,255]; % 最小值颜色

data=importdata('./blues_map.txt');
% 此处只取前列即可。
blues=data(:,1:3);

% 绘制坐标轴
m = length(confusionMat);
imagesc(1:m,1:m,confusionMat)
xticks(1:m)
xticklabels(label)
yticks(1:m)
yticklabels(label)

% 构造渐变色
mymap = [linspace(mincolor(1)/255,maxcolor(1)/255,64)',...
         linspace(mincolor(2)/255,maxcolor(2)/255,64)',...
         linspace(mincolor(3)/255,maxcolor(3)/255,64)'];


colormap(blues);
tick_cb = 0:20:100;
colorbar('FontSize', 20,'Ticks',tick_cb)

% 色块填充数字
for i = 1:m
    for j = 1:m
        if confusionMat(j,i)>60
            text(i,j,[num2str(confusionMat(j,i)),'%'],...
                'horizontalAlignment','center',...
                'verticalAlignment','middle',...
                'fontname','Arial',...
                'FontWeight','bold',...
                'Color','1,1,1',...
                'fontsize',20);
        elseif confusionMat(j,i)>0
            text(i,j,[num2str(confusionMat(j,i)),'%'],...
                'horizontalAlignment','center',...
                'verticalAlignment','middle',...
                'fontname','Arial',...
                'FontWeight','bold',...
                'fontsize',20);
        end
    end
end

% 图像坐标轴等宽
ax = gca;
ax.FontName = 'Times New Roman';
set(gca,'box','on','xlim',[0.5,m+0.5],'ylim',[0.5,m+0.5]);
set(gca,'tickdir','none','FontName','Arial','FontSize',20,'FontWeight','bold')
xlabel('Predict class','fontsize',24,'FontWeight','bold','FontName','Arial')
ylabel('Actual class','fontsize',24,'FontWeight','bold','FontName','Arial')
axis square
% 保存
%saveas(gca,'ConfusionMap.png');
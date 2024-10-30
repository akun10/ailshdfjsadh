
function P=intp2(c1,c2)
             X1 = c1(1,2:end)';
             X2 = c2(1,2:end)';
             Y1 = c1(2,2:end)';
             Y2 = c2(2,2:end)';
             P = [];
             M = 27;
             %分段情况划分,即等值线不连续,X<1 或 X>70
             %tmp1 = find(X1<1);
             %tmp11 = find(X1>70); 
             %tmp1 = [tmp1, tmp11]; 
             tmp1 = [find(X1<1),find(X1>M)];
             %分段情况划分,即等值线不连续,Y<1 或 Y>70
             %tmp2 = find(Y2<1);
             %tmp21 = find(Y2>len);
             %tmp2 = [tmp2, tmp21];
             tmp2 = [find(X2<1),find(X2>M)];
             last1_i = 1;
             for seg1_i = tmp1
                if isempty(seg1_i)
                    continue;
                end
                X1_i = X1(last1_i:seg1_i-1);
                Y1_i = Y1(last1_i:seg1_i-1);
        
                last2_i = 1;
                for seg2_i = tmp2
                    if isempty(seg2_i) %若是空的，则跳过
                        continue;
                    end
                   X2_i = X2(last2_i:seg2_i-1);
                   Y2_i = Y2(last2_i:seg2_i-1);
                   P = [P;intp_in(X1_i,X2_i,Y1_i,Y2_i)];
            
                   last2_i = seg2_i+1;
                end
                X2_i = X2(last2_i:length(X2));
                Y2_i = Y2(last2_i:length(Y2));
                P = [P;intp_in(X1_i,X2_i,Y1_i,Y2_i)];
        
                last1_i = seg1_i+1;
             end
             X1_i = X1(last1_i:length(X1));
             Y1_i = Y1(last1_i:length(Y1));
             last2_i = 1;
             for seg2_i = tmp2
                if isempty(seg2_i)
                    continue;
                end
                X2_i = X2(last2_i:seg2_i-1);
                Y2_i = Y2(last2_i:seg2_i-1);
                P = [P;intp_in(X1_i,X2_i,Y1_i,Y2_i)];
        
                last2_i = seg2_i+1;
             end
             X2_i = X2(last2_i:length(X2));
             Y2_i = Y2(last2_i:length(Y2));
             P = [P;intp_in(X1_i,X2_i,Y1_i,Y2_i)];
        end
        
        function P=intp_in(X1,X2,Y1,Y2)
            if isempty(X1) || isempty(X2)
                P = [];
                return;
            end
            if max(X1)<min(X2) || max(X2)<min(X1) || max(Y1)<min(Y2) || max(Y2)<min(Y1)
                P=[]; % 两个区间没有重叠，不可能有交点
                return;
            end
            %X方向缩小区间

            [a1,b1,a2,b2] = narrowArea(X1,X2);
            X1 = X1(a1:b1);
            Y1 = Y1(a1:b1);
            X2 = X2(a2:b2);
            Y2 = Y2(a2:b2);

            if max(X1)<min(X2) || max(X2)<min(X1) || max(Y1)<min(Y2) || max(Y2)<min(Y1)
                P=[]; % 两个区间没有重叠，不可能有交点
                return;
            end
            %Y方向缩小区间
            [a1,b1,a2,b2] = narrowArea(Y1,Y2);
            X1 = X1(a1:b1);
            Y1 = Y1(a1:b1);
            X2 = X2(a2:b2);
            Y2 = Y2(a2:b2);
            acc_n = 30;
            if length(X1)>1
                s1 = zeros(1,length(X1));
                for i = 1:length(X1)-1
                    s1(i+1) = s1(i) + sqrt((X1(i+1)-X1(i))^2+(Y1(i+1)-Y1(i))^2);
                end
                z1 = s1(1):(s1(end)-s1(1))/acc_n:s1(end);
                x_1 = interp1(s1,X1,z1,'linear');
                y_1 = interp1(s1,Y1,z1,'linear');
            else
                x_1 = X1;
                y_1 = Y1;
            end
            %在小区间内插值
            if length(X2)>1
                s2 = zeros(1,length(X2));
                for i = 1:length(X2)-1
                    s2(i+1) = s2(i) + sqrt((X2(i+1)-X2(i))^2+(Y2(i+1)-Y2(i))^2);
                end
                z2 = s2(1):(s2(end)-s2(1))/acc_n:s2(end);
                x_2 = interp1(s2,X2,z2,'linear');
                y_2 = interp1(s2,Y2,z2,'linear');
            else
                x_2 = X2;
                y_2 = Y2;
            end
            if isempty(x_1)
                P=[]; 
                return;
            end
            if max(x_1)<min(x_2) || max(x_2)<min(x_1) || max(y_1)<min(y_2) || max(y_2)<min(y_1)
                P=[]; % 两个区间没有重叠，不可能有交点
                return;
            end
    
        
            [a1,b1,a2,b2] = narrowArea(x_1,x_2);
            P = [];
            if (b1 == a1) && (b2 == a2)
                if (x_1 == x_2) && (y_1 == y_2)
                    P = [P,[x_1,y_1]];
                end
            elseif b1 == a1
                for j = a2:b2-1
                    if x_1>=min(x_2(j:j+1)) && x_1<=max(x_2(j:j+1)) && y_1<=max(y_2(j:j+1)) && y_1>=min(y_2(j:j+1))
                        lineseg_A = [x_1,y_1;x_1,y_1];
                        lineseg_B = [x_2(j),y_2(j);x_2(j+1),y_2(j+1)];
                        [Xi,Yi] = polyxpoly(lineseg_A(:,1),lineseg_A(:,2),lineseg_B(:,1),lineseg_B(:,2));
                        if isempty([Xi,Yi]) == 0          
                            P=[P;[Xi,Yi]];
                        end
                    end
                end
            elseif b2 == a2
                for j = a1:b1-1
                    if x_2>=min(x_1(j:j+1)) && x_2<=max(x_1(j:j+1)) && y_2<=max(y_1(j:j+1)) && y_2>=min(y_1(j:j+1))
                        lineseg_A = [x_2,y_2;x_2,y_2];
                        lineseg_B = [x_1(j),y_1(j);x_1(j+1),y_1(j+1)];
                        [Xi,Yi] = polyxpoly(lineseg_A(:,1),lineseg_A(:,2),lineseg_B(:,1),lineseg_B(:,2));
                        if isempty([Xi,Yi]) == 0          
                            P=[P;[Xi,Yi]];
                        end
                    end
                end
            else
                for i = a1:b1-1
                    for j = a2:b2-1
                        if max(x_1(i:i+1))>=min(x_2(j:j+1)) && min(x_1(i:i+1))<=max(x_2(j:j+1)) && min(y_1(i:i+1))<=max(y_2(j:j+1)) && max(y_1(i:i+1))>=min(y_2(j:j+1))
                            %[Xi,Yi]=pll(x_1(i:i+1),y_1(i:i+1),x_2(i:i+1),y_2(i:i+1));
                            %处理不了重合的点
                            lineseg_A = [x_1(i),y_1(i);x_1(i+1),y_1(i+1)];
                            lineseg_B = [x_2(j),y_2(j);x_2(j+1),y_2(j+1)];
                            [Xi,Yi] = polyxpoly(lineseg_A(:,1),lineseg_A(:,2),lineseg_B(:,1),lineseg_B(:,2));
                            if isempty([Xi,Yi]) == 0          
                                P=[P;[Xi,Yi]];
                            end
                        end
                    end
                end
            end
        end
        %缩小区间
        function [a1,b1,a2,b2] = narrowArea(X1,X2)
            a=max(min(X1),min(X2));
            b=min(max(X1),max(X2));
            a1=find(X1>=a);
            if length(a1)>=1
                a1=a1(1);
            end
            a2=find(X2>=a);
            if length(a2)>=1
                a2=a2(1);
            end
            
            b1=find(X1<=b); 
            if ~isempty(b1)
                b1=b1(end);
            end
            b2=find(X2<=b); 
            if ~isempty(b2)
                b2=b2(end);
            end
            %这里需要处理，否则可能删掉有用数据
            if a1 > 1
                a1 = a1-1;
            end
            if a2 > 1
                a2 = a2-1;
            end
            if b1 < length(X1)
                b1 = b1+1;
            end
            if b2 < length(X2)
                b2 = b2+1;
            end
        end
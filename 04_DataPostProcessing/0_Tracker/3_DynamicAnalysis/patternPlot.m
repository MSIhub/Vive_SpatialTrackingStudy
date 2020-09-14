% XPattern = load('data/XPattern_Tracker.txt');
% YPatternO2V2 = load('data/YPattern_Tracker_O2_V2.txt');
% YPatternV2 = load('data/YPattern_Tracker_V2.txt');
% 
% figure()
% hold on;
% plot(XPattern(:,1),XPattern(:,2));
% plot(YPatternO2V2(:,1),YPatternO2V2(:,2));
% plot(YPatternV2(:,1),YPatternV2(:,2));
% axis equal;


load WP_X;
load WP_Y;

%% Plotting for journal
figure()
pattern = 'Y';
plot( WP_Y(:,1),WP_Y(:,2),'mo'); hold on;
% lines
clear i j
for i = 1:3:16
    j = i +1;
    plot( WP_Y(i:j,1),WP_Y(i:j,2),'m-.'); hold on;
end
clear i j
for i = 18:3:33
    j = i +1;
    plot( WP_Y(i:j,1),WP_Y(i:j,2),'m-.'); hold on;
end
% semicircles
count = 0;
for i =2:3:16
    j = i +2;
    count = count +1;
    if  ~mod(count,2)
        sign = false;
    else
        sign = true;
    end
    semicircle(WP_Y(i,1:2) ,WP_Y(j,1:2), sign,pattern, '-.', 'm');hold on;
end
count = 0;
for i =19:3:32
    j = i +2; 
    count = count +1;
    if  ~mod(count,2)
        sign = true;
    else
        sign = false;
    end
    semicircle(WP_Y(i,1:2) ,WP_Y(j,1:2), sign, pattern, '-.', 'm');hold on;
end


plot(WP_Y(1,1),WP_Y(1,2),'gd','MarkerSize',10); hold on;
plot(WP_Y(end,1),WP_Y(end,2),'rs','MarkerSize',10); hold on;

%% Plotting for journal
pattern = 'X';

plot( WP_X(:,1),WP_X(:,2),'o', 'color', ' [ 0.9100 0.4100 0.1700]'); hold on;
% lines
clear i j
for i = 1:3:size(WP_X,1)
    j = i +1;
    plot( WP_X(i:j,1),WP_X(i:j,2),'-','color', ' [ 0.9100 0.4100 0.1700]'); hold on;
end
% semicircles
clear i j count
count = 0;
for i =2:3:size(WP_X,1)-2
    j = i +2;
    count = count +1;
    if  ~mod(count,2)
        sign = false;
    else
        sign = true;
    end
    semicircle(WP_X(i,1:2) ,WP_X(j,1:2), sign,pattern,'-','[ 0.9100 0.4100 0.1700]' );hold on;
end

plot(WP_X(1,1),WP_X(1,2),'gd','MarkerSize',10); hold on;
plot(WP_X(end,1),WP_X(end,2),'rs','MarkerSize',10); hold on;
xlabel('X axis of C16 workspace [mm]')
ylabel('Y axis of C16 workspace [mm]')
axis equal
grid on;
hold off;
FontSize = 9;
LineWidth = 1.2;
set(gca, 'FontName', 'CMU Serif','fontweight','bold','FontSize',FontSize,'TickLabelInterpreter','latex');
set(gcf, 'Units', 'centimeters','Position',  [24.60625,19.596805555555555,9.68375,7.196666666666665], 'InnerPosition', [24.60625,19.596805555555555,9.68375,7.196666666666665], 'OuterPosition', [24.412222222222223,19.402777777777775,10.071805555555553,9.507361111111113]);
set(gcf,'Renderer', 'painters', 'RendererMode', 'manual');

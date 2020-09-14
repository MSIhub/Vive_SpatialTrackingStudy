XPattern = load('data/XPattern_Tracker.txt');
YPatternO2V2 = load('data/YPattern_Tracker_O2_V2.txt');
YPatternV2 = load('data/YPattern_Tracker_V2.txt');

figure()
hold on;
plot(XPattern(:,1),XPattern(:,2));
plot(YPatternO2V2(:,1),YPatternO2V2(:,2));
plot(YPatternV2(:,1),YPatternV2(:,2));
axis equal;
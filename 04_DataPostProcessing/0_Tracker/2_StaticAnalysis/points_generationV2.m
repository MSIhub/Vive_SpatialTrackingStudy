%% Randomly generated points
clear all; close all; clc;

filename = 'PathData/SA_V2.txt';
rng('default')
num_of_wayPoints = 50;
xlim = [-1.0 1.0];
ylim1 = [-0.7 -0.3];
ylim2 = [0.3 0.7];
zlim = [1.5 1.65];
wayPoints1(:,1) = round(((xlim(2)-xlim(1)).*rand(num_of_wayPoints,1) + xlim(1)), 4);
wayPoints1(:,2) = round(((ylim1(2)-ylim1(1)).*rand(num_of_wayPoints,1) + ylim1(1)), 4);
wayPoints1(:,3) = round(((zlim(2)-zlim(1)).*rand(num_of_wayPoints,1) + zlim(1)), 4);

wayPoints2(:,1) = round(((xlim(2)-xlim(1)).*rand(num_of_wayPoints,1) + xlim(1)), 4);
wayPoints2(:,2) = round(((ylim2(2)-ylim2(1)).*rand(num_of_wayPoints,1) + ylim2(1)), 4);
wayPoints2(:,3) = round(((zlim(2)-zlim(1)).*rand(num_of_wayPoints,1) + zlim(1)), 4);

% adding the orientation of the calibrated cube
wayPoints1 = [wayPoints1(:,1),wayPoints1(:,2), wayPoints1(:,3),...
    -88*ones(length(wayPoints1(:,2)),1), 45*ones(length(wayPoints1(:,2)),1), 0*ones(length(wayPoints1(:,2)),1)];

wayPoints2 = [wayPoints2(:,1),wayPoints2(:,2), wayPoints2(:,3),...
    88*ones(length(wayPoints2(:,2)),1), 45*ones(length(wayPoints2(:,2)),1), 0*ones(length(wayPoints2(:,2)),1)];

wayPoints = [wayPoints1; wayPoints2];
scatter3(wayPoints(:,1), wayPoints(:,2), wayPoints(:,3),'r*');
axis equal

% Converting to mm and deg
wayPoints(:,1:3) = round(wayPoints(:,1:3).*1000,3);


writematrix(wayPoints,filename,'Delimiter',',');
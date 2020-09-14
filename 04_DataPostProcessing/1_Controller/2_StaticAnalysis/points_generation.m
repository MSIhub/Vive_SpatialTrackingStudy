%% Randomly generated points


filename = 'SA_C.txt';
rng('default')
num_of_wayPoints = 100;
xlim = [-0.5 0.5];
ylim = [-1.3 -0.8];
zlim = [1.1 1.6];
wayPoints(:,1) = round(((xlim(2)-xlim(1)).*rand(num_of_wayPoints,1) + xlim(1)), 4);
wayPoints(:,2) = round(((ylim(2)-ylim(1)).*rand(num_of_wayPoints,1) + ylim(1)), 4);
wayPoints(:,3) = round(((zlim(2)-zlim(1)).*rand(num_of_wayPoints,1) + zlim(1)), 4);
scatter3(wayPoints(:,1), wayPoints(:,2), wayPoints(:,3),'r*');
axis equal

% adding the orientation of the calibrated cube
wayPoints = [wayPoints(:,1),wayPoints(:,2), wayPoints(:,3),...
    -88*ones(length(wayPoints(:,2)),1), 45*ones(length(wayPoints(:,2)),1), 68*ones(length(wayPoints(:,2)),1)];
% Converting to mm and deg
wayPoints(:,1:3) = wayPoints(:,1:3).*1000;
writematrix(wayPoints,filename,'Delimiter',',');
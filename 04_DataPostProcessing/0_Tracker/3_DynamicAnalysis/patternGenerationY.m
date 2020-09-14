close all; clear all; clc;

% X pattern
% init_offset = [-1239 ; -1000];
%init_offset = [1250 ; 1050];
init_offset = [-1000 ; -1160];


length = 2500; %mm
width = 1200; %mm
length_of_bar = 350 + 6.4 ; %mm

d_p = length_of_bar ; % distance between paths
d_b = 0.5*length_of_bar; % distance of path with boundary
r = 0.5 *length_of_bar; % radius of circular connectors of each path with other

number_of_path = round((length - (2 * d_b))/d_p) ;
l1 = width - (2*d_b) - r;
l2 = width - (2*d_b) - (2*r);

start = init_offset - [-d_b; -d_b] ;
W = zeros(2,(number_of_path*3)-1);
sign = 1;
% 2nd point
W(:,1) = start;
W(:,2) = start + [0;l1];
W(:,3) = W(:,2) + [r;r];
W(:,4) = W(:,2) + [d_p;0];
for itr1 = 5:3:size(W,2)-1
    if(bitget(itr1,1))
       flag = -1;
    else
        flag = 1;
    end
    W(:,itr1) = W(:,itr1-1) + [0;flag*l2];
    W(:,itr1+1) = W(:,itr1) + [r;flag*r];
    W(:,itr1+2) = W(:,itr1) + [d_p;0];
end
W(:,end) = W(:,end-1) + [0;-flag*l1]; % finish

WP = zeros(size(W,2),6);
WP(:,1) = (W(1,:));
WP(:,2) = (W(2,:));
WP(:,3) = 1650;
WP(:,4) = 0;
WP(:,5) = 0;
WP(:,6) = 0;
% As the end point was out of reach, I change just the end point
%WP(end,1) = WP(end,1) + 0.6*r; 
WP = round(WP,3);
writematrix(WP,'data/Ypattern_Tracker.txt');




figure()
plot( WP(:,1),WP(:,2),'ko-'); hold on;
plot(WP(1,1),WP(1,2),'g*'); hold on;
plot(WP(end,1),WP(end,2),'r*'); hold on;
xlabel("X")
ylabel('Y')
axis equal

disp("X")
min(WP(:,1))
max(WP(:,1))
diffX = max(WP(:,1))- min(WP(:,1))

disp("Y")
min(WP(:,2))
max(WP(:,2))
diffY = max(WP(:,2))- min(WP(:,2))



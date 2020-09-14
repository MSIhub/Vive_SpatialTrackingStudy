close all; clear all; clc;

init_offset = [-1250 ; 130];
length = 2500; %mm
width = 1200; %mm
length_of_bar = 350 + 6.4 ; %mm
d_p = length_of_bar ; % distance between paths
d_b = 0.5*length_of_bar; % distance of path with boundary
r = 0.5 *length_of_bar; % radius of circular connectors of each path with other
number_of_path = round((length - (2 * d_b))/d_p) ;
l1 = width - (2*d_b) - r;
l2 = width - (2*d_b) - (2*r);

start = init_offset - [-d_b; d_b] ;
W1 = zeros(2,(number_of_path*3)-1);
sign = 1;
W1 = zeros(2,(number_of_path*3)-1);
W2 = zeros(2,(number_of_path*3)-1);
sign = 1;
% 2nd point
W1(:,1) = start;
W1(:,2) = start + [0;-l1];
W1(:,3) = W1(:,2) + [r;-r];
W1(:,4) = W1(:,2) + [d_p;0];
for itr1 = 5:3:size(W1,2)-1
    if(bitget(itr1,1))
       flag = 1;
    else
        flag = -1;
    end
    W1(:,itr1) = W1(:,itr1-1) + [0;flag*l2];
    W1(:,itr1+1) = W1(:,itr1) + [r;flag*r];
    W1(:,itr1+2) = W1(:,itr1) + [d_p;0];
end
W1(:,end) = W1(:,end-1) + [0;-flag*l1]; % finish


% 2nd point
W2(:,1) = W1(:,end);
W2(:,2) = W1(:,end) + [0;1.1*l1];
W2(:,3) = W2(:,2) + [-r;r];
W2(:,4) = W2(:,2) + [-d_p;0];
for itr1 = 5:3:size(W2,2)-1
    if(bitget(itr1,1))
       flag = -1;
    else
        flag = 1;
    end
    W2(:,itr1) = W2(:,itr1-1) + [0;flag*0.9*l2];
    W2(:,itr1+1) = W2(:,itr1) + [-r;flag*r];
    W2(:,itr1+2) = W2(:,itr1) + [-d_p;0];
end
W2(:,end) = W2(:,end-1) + [0;-flag*l1]; % finish

WP_Y = zeros(size(W1,2)+ size(W1,2),6);
WP_Y(:,1) = [(W1(1,:)), (W2(1,:))];
WP_Y(:,2) = [(W1(2,:)), (W2(2,:))];
WP_Y(:,3) = 1650;
WP_Y(1:end,4) = 0;
WP_Y(:,5) = 0;
WP_Y(:,6) = 0;
% As the end point was out of reach, I change just the end point
%WP(end,1) = WP(end,1) + 0.6*r; 
WP_Y = round(WP_Y,3);
% writematrix(WP,'data/Ypattern_Tracker_V2.txt');
save WP_Y
% 
% figure()
% plot( WP(:,1),WP(:,2),'ko-'); hold on;
% plot(WP(1,1),WP(1,2),'g*'); hold on;
% plot(WP(end,1),WP(end,2),'r*'); hold on;
% xlabel("X")
% ylabel('Y')
% axis equal

% disp("X")
% min(WP(:,1))
% max(WP(:,1))
% diffX = max(WP(:,1))- min(WP(:,1))
% 
% disp("Y")
% min(WP(:,2))
% max(WP(:,2))
% diffY = max(WP(:,2))- min(WP(:,2))

%% Plotting for journal
pattern = 'Y'
figure()
plot( WP_Y(2:end-1,1),WP_Y(2:end-1,2),'ko'); hold on;
% lines
clear i j
for i = 1:3:16
    j = i +1;
    plot( WP_Y(i:j,1),WP_Y(i:j,2),'k-'); hold on;
end
clear i j
for i = 18:3:33
    j = i +1;
    plot( WP_Y(i:j,1),WP_Y(i:j,2),'k-'); hold on;
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
    semicircle(WP_Y(i,1:2) ,WP_Y(j,1:2), sign,'k-',pattern);hold on;
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
    semicircle(WP_Y(i,1:2) ,WP_Y(j,1:2), sign,'k-',pattern);hold on;
end


plot(WP_Y(1,1),WP_Y(1,2),'gd'); hold on;
plot(WP_Y(end,1),WP_Y(end,2),'rs'); hold on;
xlabel("X")
ylabel('Y')
axis equal


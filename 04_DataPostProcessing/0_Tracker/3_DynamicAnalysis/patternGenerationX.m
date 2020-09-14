close all; clear ; clc;

% X pattern
% init_offset = [-1239 ; -1000];
init_offset = [-1250 ; -1050];

length = 2500; %mm
width = 2000; %mm
length_of_bar = 350 + 4; %mm

d_p = length_of_bar; % distance between paths
d_b = 0.5*length_of_bar; % distance of path with boundary
r = 0.5 *length_of_bar; % radius of circular connectors of each path with other

number_of_path = round((width - (2 * d_b))/d_p) ;
l1 = length - (2*d_b) - r;
l2 = length - (2*d_b) - (2*r);

start = [d_b; d_b] + init_offset;
W = zeros(2,(number_of_path*3)-1);
sign = 1;
% 2nd point
W(:,1) = start;
W(:,2) = start + [l1;0];
W(:,3) = W(:,2) + [r;r];
W(:,4) = W(:,2) + [0;d_p];
for itr1 = 5:3:size(W,2)-1
    if(bitget(itr1,1))
       flag = -1;
    else
        flag = 1;
    end
    W(:,itr1) = W(:,itr1-1) + [flag*l2;0];
    W(:,itr1+1) = W(:,itr1) + [flag*r;r];
    W(:,itr1+2) = W(:,itr1) + [0;d_p];
end
W(:,end) = W(:,end-1) + [-flag*l1;0]; % finish

WP_X = zeros(size(W,2),6);
WP_X(:,1) = flip(W(1,:));
WP_X(:,2) = flip(W(2,:));
WP_X(:,3) = 1770;%1650;
WP_X(:,4) = 0;
WP_X(:,5) = 0;
WP_X(:,6) = 0;
% As the end point was out of reach, I change just the end point
WP_X(end,1) = WP_X(end,1) + 0.6*r; 
% writematrix(WP,'data/XO1.txt');
save WP_X


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
pattern = 'X';
figure()
plot( WP_X(2:end-1,1),WP_X(2:end-1,2),'ko'); hold on;
% lines
clear i j
for i = 1:3:size(WP_X,1)
    j = i +1;
    plot( WP_X(i:j,1),WP_X(i:j,2),'k-'); hold on;
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
    semicircle(WP_X(i,1:2) ,WP_X(j,1:2), sign,'k-',pattern);hold on;
end

plot(WP_X(1,1),WP_X(1,2),'gd'); hold on;
plot(WP_X(end,1),WP_X(end,2),'rs'); hold on;
xlabel("X")
ylabel('Y')
axis equal



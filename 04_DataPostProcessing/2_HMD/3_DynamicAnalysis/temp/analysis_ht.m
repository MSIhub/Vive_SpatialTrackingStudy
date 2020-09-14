clear; close all; clc;

% final results in mm and deg
data = struct();
% data.I1 = load("Results\DA_T_Init_I1.mat");
% data.I2 = load("Results\DA_T_Init_I2.mat");
% data.I3 = load("Results\DA_T_Init_I3.mat");
velName = "HT";
data.SS1 = load(['Results\DA_T_', char(velName),'_SS1.mat']);
% data.YO1 = load(['Results\DA_T_', char(velName),'_YO1.mat']);
% data.XO2 = load(['Results\DA_T_', char(velName),'_XO2.mat']);
% data.YO2 = load(['Results\DA_T_', char(velName),'_YO2.mat']);
% data.XO3 = load(['Results\DA_T_', char(velName),'_XO3.mat']);
% data.YO3 = load(['Results\DA_T_', char(velName),'_YO3.mat']);
resultFile = ['Results\DA_T_', char(velName),'.mat'];
nT= [];
theta = [];
vel =[];
timestamp = [];

fields = fieldnames(data);
for itr1 = 1:1:length(fields)
    nT = [nT; data.(fields{itr1}).nT * 1000]; % m to mm
    theta = [theta; (data.(fields{itr1}).theta) *(180/pi)]; % rad to deg
    vel = [vel; data.(fields{itr1}).vel * 1000]; % m/s to mm/s
    timestamp = [timestamp; data.(fields{itr1}).timestamp];
end

Vel_avg = mean(vel);
Vel_max = max(vel);

% %%% INIT Results %%%
% nT_m= mean(nT)
% theta_m = median(theta)
% 
% figure()
% hold on
% plot(theta)
% plot(theta_m*ones(size(theta)))

%% Error statistic using Reference System data
nT_ref = 0.3578 * 1000; % meters
theta_ref = 3.1072 * (180/pi); % radians

dd = 3;% round decimal digit
errorStat = struct();
% (35560:973200)
e_p = abs(nT - nT_ref);
errorStat.e_p = e_p;
errorStat.rsme_p = round(sqrt(sum(e_p.^2)/length(e_p)), dd);
errorStat.maxe_p = round(max(e_p), dd);
E_p = sort(e_p);
errorStat.E50_p = round(prctile(E_p,50), dd);
errorStat.E95_p = round(prctile(E_p,95), dd);
errorStat.E99_7_p = round(prctile(E_p,99.7), dd);
errorStat.ebar_p = sum(e_p)/length(e_p);
errorStat.s_sqr_p = sum((e_p - errorStat.ebar_p ).^2) / (length(e_p) -1);

e_o = abs(theta_ref - theta) ;
errorStat.e_o = e_o;
errorStat.rsme_o = round(sqrt(sum(e_o.^2)/length(e_o)), dd);
errorStat.maxe_o = round(max(e_o), dd);
E_o = sort(e_o);
errorStat.E50_o = round(prctile(E_o,50), dd);
errorStat.E95_o = round(prctile(E_o,95), dd);
errorStat.E99_7_o = round(prctile(E_o,99.7), dd);
errorStat.ebar_o = sum(e_o)/length(e_o);
errorStat.s_sqr_o = sum((e_o - errorStat.ebar_o ).^2) / (length(e_o) -1);
%% Repeatability without Reference system
repeatStat = struct();

d_p = abs(nT - mean(nT));
repeatStat.rsmd_p = round(sqrt(sum(d_p.^2)/length(d_p)), dd);
repeatStat.maxd_p = round(max(d_p), dd);
D_p = sort(d_p);
repeatStat.D50_p = round(prctile(D_p,50), dd);
repeatStat.D95_p = round(prctile(D_p,95), dd);
repeatStat.D99_7_p = round(prctile(D_p,99.7), dd);


d_o = abs(theta - mean(theta)) ;
repeatStat.rsmd_o = round(sqrt(sum(d_o.^2)/length(d_o)), dd);
repeatStat.maxd_o = round(max(d_o), dd);
D_o = sort(d_o);
repeatStat.D50_o = round(prctile(D_o,50), dd);
repeatStat.D95_o = round(prctile(D_o,95), dd);
repeatStat.D99_7_o = round(prctile(D_o,99.7), dd);

%% Saving results to a txt file
save(resultFile,'errorStat', 'repeatStat', 'vel', 'Vel_avg', 'Vel_max');
% regtest = [vel, e_p];
% save('Results/DA_test.mat','regtest');
% [R,P,RL,RU]  = corrcoef(vel, e_p);

% coeff = pca(regtest);
% %% Plots
% figure()
% scatter(vel,e_p,'.');
% % 
% figure()
% scatter(vel, e_o,'.');
% % 
% figure()
% scatter(vel, nT,'.');
% 
% [vel_sort,b]= sort(vel);
% e_p_sort = e_p(b);
% 
% % aa = find(round(vel_sort) < 900 & round(vel_sort) > 700);
% aa = find(round(vel_sort) == 800);
% 
% figure()
% plot(vel_sort(aa),e_p_sort(aa),'.');
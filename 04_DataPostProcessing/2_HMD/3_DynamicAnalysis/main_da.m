clear; close all; clc;
%% Loading files (tracker and comau)
FLOAT_PRECISION = 8;
% velName = "V0_050";
% repoName = ["XO1","YO1", "XO2", "YO2", "XO3", "YO3"];


velName = "HT";
repoName = ["PF2"];%[ "SM1", "SF1", "PS1", "PM1", "PF1", "PM2", "PF2"];

for itr1 = 1:1:length(repoName)
    resultFile = ['Results/DA_H_',char(velName),'_',char(repoName(itr1)),'.mat'];
    P = ['./RawData/',char(velName),'/',char(repoName(itr1))];
    S = dir(fullfile(P,'*.txt'));
    N = {S.name};
    X1 = contains(N,"rawComauData");
    X2 = contains(N,"rawViveDataHMD");
    filenameComau = fullfile(P,N{X1});
    filenameHmd = fullfile(P,N{X2});
    filenameController = "";
    filenameTracker = "";
    %% PARAM
    isCalibrationOn = false;
    delimiterV = ",";
    delimiterC = ",";
    resamplingRate = 100;
    %###################################################################%%
    %% Loading and post proccesing data for comau and vive
    Comau = comauPP(filenameComau,delimiterC);
    Vive = vivePP(filenameHmd,filenameController,filenameTracker, delimiterV);
    %###################################################################%%
    %% Synchronising vive and comau
    %out: point correspondance data V: vive struct, C:comau array
    [V,C] = syncViveComau(Comau,Vive, resamplingRate);
    
    % calculate nT and theta
    % Relative Pose error calculation
    % transform the pose of all points with respect to the first point in each
    % frame
    data.C = C;
    data.V = V.hmd;
    
    [T_v1,T_c1] = TmatVC(data.V(10,:), data.C(10,:));
    for itr2 = 1:1:length(data.V)
        [T_vk, T_ck] = TmatVC(data.V(itr2,:), data.C(itr2,:));
        T_V = T_v1\T_vk;
        T_C = T_c1\T_ck;
        DA_H_Stat.e_p(itr2,1) = abs((norm(T_V(1:3,4)) - norm(T_C(1:3,4)))); 
        R_diff =  round(T_C(1:3,1:3) * transpose(T_V(1:3,1:3)),8); 
        DA_H_Stat.e_o(itr2,1) = abs(acos((trace(R_diff)-1)/2) ); 
    end
   
    
    %Average measurement error
    DA_H_Stat.ebar_p = sum(DA_H_Stat.e_p)/length(DA_H_Stat.e_p);
    DA_H_Stat.ebar_o = sum(DA_H_Stat.e_o)/length(DA_H_Stat.e_o);
    
    % Variance
    DA_H_Stat.s_sqr_p = sum((DA_H_Stat.e_p - DA_H_Stat.ebar_p).^2) / (length(DA_H_Stat.e_p) -1);
    DA_H_Stat.s_sqr_o = sum((DA_H_Stat.e_o - DA_H_Stat.ebar_o).^2) / (length(DA_H_Stat.e_o) -1);
    %%%
    DA_H_Stat.rmse_p = sqrt(sum(DA_H_Stat.e_p .^2)/length(DA_H_Stat.e_p ));
    DA_H_Stat.maxe_p = max(DA_H_Stat.e_p);
    combo_E_p = sort(DA_H_Stat.e_p );
    DA_H_Stat.E50_p = prctile(combo_E_p,50);
    DA_H_Stat.E95_p = prctile(combo_E_p,95);
    DA_H_Stat.E99_7_p = prctile(combo_E_p,99.7);
    
    
    DA_H_Stat.rmse_o = sqrt(sum(DA_H_Stat.e_o .^2)/length(DA_H_Stat.e_o ));
    DA_H_Stat.maxe_o = max(DA_H_Stat.e_o);
    combo_E_o = sort(DA_H_Stat.e_o);
    DA_H_Stat.E50_o = prctile(combo_E_o,50);
    DA_H_Stat.E95_o = prctile(combo_E_o,95);
    DA_H_Stat.E99_7_o = prctile(combo_E_o,99.7);
    

    vel = C(:,8);
    vel_avg = mean(vel);
    vel_max = max(vel);

    % Saving to mat file
    save(resultFile, 'DA_H_Stat', 'vel', 'vel_avg', 'vel_max');
end

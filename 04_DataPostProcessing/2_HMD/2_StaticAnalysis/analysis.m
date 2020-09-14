clear; clc; close all;
fileName = 'Results/SA_H.mat';
data = load(fileName);
fields = fieldnames(data);

% Relative Pose error calculation
% transform the pose of all points with respect to the first point in each
% frame
[T_v1,T_c1] = TmatVC(data.P1.V(1,:), data.P1.C(1,:));
R_v1 = T_v1(1:3,1:3);
R_c1 = T_c1(1:3,1:3);

for itr1 = 1:1:length(fields)
    for itr2 = 1:1:length(data.(fields{itr1}).V)
        [T_vk, T_ck] = TmatVC(data.(fields{itr1}).V(itr2,:), data.(fields{itr1}).C(itr2,:));
        T_V = T_v1\T_vk;
        T_C = T_c1\T_ck;
        SA_H_Stat.(fields{itr1}).e_p(itr2,1) = abs((norm(T_V(1:3,4)) - norm(T_C(1:3,4)))* 1000); %mm
        R_diff =  round(T_C(1:3,1:3) * transpose(T_V(1:3,1:3)),8); % round to less digit will yield in zero angle and rounding to much higher will lead to complex number gen
        SA_H_Stat.(fields{itr1}).e_o(itr2,1) = abs(acos((trace(R_diff)-1)/2) * (180/pi)); % deg
    end
end

% Box plot
SA_H_Stat_Combo.e_p = [];
SA_H_Stat_Combo.e_o = [];
for itr3 = 1:1:length(fields)
    SA_H_Stat_Combo.e_p = [ SA_H_Stat_Combo.e_p; SA_H_Stat.(fields{itr3}).e_p];
    SA_H_Stat_Combo.e_o = [ SA_H_Stat_Combo.e_o; SA_H_Stat.(fields{itr3}).e_o];
end

%Average measurement error
SA_H_Stat_Combo.ebar_p = sum(SA_H_Stat_Combo.e_p)/length(SA_H_Stat_Combo.e_p);
SA_H_Stat_Combo.ebar_o = sum(SA_H_Stat_Combo.e_o)/length(SA_H_Stat_Combo.e_o);

% Variance
SA_H_Stat_Combo.s_sqr_p = sum((SA_H_Stat_Combo.e_p - SA_H_Stat_Combo.ebar_p).^2) / (length(SA_H_Stat_Combo.e_p) -1);
SA_H_Stat_Combo.s_sqr_o = sum((SA_H_Stat_Combo.e_o - SA_H_Stat_Combo.ebar_o).^2) / (length(SA_H_Stat_Combo.e_o) -1);
%%%
SA_H_Stat_Combo.rmse_p = sqrt(sum(SA_H_Stat_Combo.e_p .^2)/length(SA_H_Stat_Combo.e_p ));
SA_H_Stat_Combo.maxe_p = max(SA_H_Stat_Combo.e_p);
combo_E_p = sort(SA_H_Stat_Combo.e_p );
SA_H_Stat_Combo.E50_p = prctile(combo_E_p,50);
SA_H_Stat_Combo.E95_p = prctile(combo_E_p,95);
SA_H_Stat_Combo.E99_7_p = prctile(combo_E_p,99.7);


SA_H_Stat_Combo.rmse_o = sqrt(sum(SA_H_Stat_Combo.e_o .^2)/length(SA_H_Stat_Combo.e_o ));
SA_H_Stat_Combo.maxe_o = max(SA_H_Stat_Combo.e_o);
combo_E_o = sort(SA_H_Stat_Combo.e_o);
SA_H_Stat_Combo.E50_o = prctile(combo_E_o,50);
SA_H_Stat_Combo.E95_o = prctile(combo_E_o,95);
SA_H_Stat_Combo.E99_7_o = prctile(combo_E_o,99.7);

resultFile = 'Results/SA_H_Stat.mat';
save(resultFile,'SA_H_Stat' ,'SA_H_Stat_Combo');

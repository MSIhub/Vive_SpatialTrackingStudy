clear; clc; close all;
fileName = 'Results/SA_T.mat';
data = load(fileName);
fields = fieldnames(data);

% Relative Pose error calculation
% transform the pose of all points with respect to the first point in each
% frame
[T_v1,T_c1] = TmatVC(data.P45.V(1,:), data.P45.C(1,:));
for itr1 = 1:1:(0.5*length(fields))
    for itr2 = 1:1:length(data.(fields{itr1}).V)
        [T_vk, T_ck] = TmatVC(data.(fields{itr1}).V(itr2,:), data.(fields{itr1}).C(itr2,:));
        T_V = T_v1\T_vk;
        T_C = T_c1\T_ck;
        SA_T_Stat.(fields{itr1}).e_p(itr2,1) = abs((norm(T_V(1:3,4)) - norm(T_C(1:3,4)))* 1000); %mm
        R_diff =  round(T_C(1:3,1:3) * transpose(T_V(1:3,1:3)),8); % round to less digit will yield in zero angle and rounding to much higher will lead to complex number gen
        SA_T_Stat.(fields{itr1}).e_o(itr2,1) = abs(acos((trace(R_diff)-1)/2) * (180/pi)); % deg
    end
end
[T_v2,T_c2] = TmatVC(data.P75.V(1,:), data.P75.C(1,:));
for itr3 =(0.5*length(fields))+1 :1: length(fields)
    for itr4 = 1:1:length(data.(fields{itr3}).V)
        [T_vk, T_ck] = TmatVC(data.(fields{itr3}).V(itr4,:), data.(fields{itr3}).C(itr4,:));
        T_V = T_v2\T_vk;
        T_C = T_c2\T_ck;
        SA_T_Stat.(fields{itr3}).e_p(itr4,1) = abs((norm(T_V(1:3,4)) - norm(T_C(1:3,4)))* 1000); %mm
        R_diff =  round(T_C(1:3,1:3) * transpose(T_V(1:3,1:3)),8); % round to less digit will yield in zero angle and rounding to much higher will lead to complex number gen
        SA_T_Stat.(fields{itr3}).e_o(itr4,1) = abs(acos((trace(R_diff)-1)/2) * (180/pi)); % deg
    end
end

% Box plot
SA_T_Stat_Combo.e_p = [];
SA_T_Stat_Combo.e_o = [];
for itr3 = 1:1:length(fields)
    SA_T_Stat_Combo.e_p = [ SA_T_Stat_Combo.e_p; SA_T_Stat.(fields{itr3}).e_p];
    SA_T_Stat_Combo.e_o = [ SA_T_Stat_Combo.e_o; SA_T_Stat.(fields{itr3}).e_o];
end
% SA_T_Stat_Combo.e_p(18930:19540,:) = [];
% SA_T_Stat_Combo.e_p(55450:56270,:) = [];

%Average measurement error
SA_T_Stat_Combo.ebar_p = sum(SA_T_Stat_Combo.e_p)/length(SA_T_Stat_Combo.e_p);
SA_T_Stat_Combo.ebar_o = sum(SA_T_Stat_Combo.e_o)/length(SA_T_Stat_Combo.e_o);

% Variance
SA_T_Stat_Combo.s_sqr_p = sum((SA_T_Stat_Combo.e_p - SA_T_Stat_Combo.ebar_p).^2) / (length(SA_T_Stat_Combo.e_p) -1);
SA_T_Stat_Combo.s_sqr_o = sum((SA_T_Stat_Combo.e_o - SA_T_Stat_Combo.ebar_o).^2) / (length(SA_T_Stat_Combo.e_o) -1);
%%%
SA_T_Stat_Combo.rmse_p = sqrt(sum(SA_T_Stat_Combo.e_p .^2)/length(SA_T_Stat_Combo.e_p ));
SA_T_Stat_Combo.maxe_p = max(SA_T_Stat_Combo.e_p);
combo_E_p = sort(SA_T_Stat_Combo.e_p );
SA_T_Stat_Combo.E50_p = prctile(combo_E_p,50);
SA_T_Stat_Combo.E95_p = prctile(combo_E_p,95);
SA_T_Stat_Combo.E99_7_p = prctile(combo_E_p,99.7);


SA_T_Stat_Combo.rmse_o = sqrt(sum(SA_T_Stat_Combo.e_o .^2)/length(SA_T_Stat_Combo.e_o ));
SA_T_Stat_Combo.maxe_o = max(SA_T_Stat_Combo.e_o);
combo_E_o = sort(SA_T_Stat_Combo.e_o);
SA_T_Stat_Combo.E50_o = prctile(combo_E_o,50);
SA_T_Stat_Combo.E95_o = prctile(combo_E_o,95);
SA_T_Stat_Combo.E99_7_o = prctile(combo_E_o,99.7);

resultFile = 'Results/SA_T_Stat.mat';
save(resultFile,'SA_T_Stat' ,'SA_T_Stat_Combo');

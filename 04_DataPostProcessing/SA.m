clear; close all; clc;

load('./0_Tracker/2_StaticAnalysis/Results/SA_T_Stat.mat');
load('./1_Controller/2_StaticAnalysis/Results/SA_C_Stat.mat');
load('./2_HMD/2_StaticAnalysis/Results/SA_H_Stat.mat');

T_ep = SA_T_Stat_Combo.e_p;
C_ep = SA_C_Stat_Combo.e_p;
H_ep = SA_H_Stat_Combo.e_p;

% % CDF
figure()
createFitSA_dp(T_ep,C_ep,H_ep)


T_eo = SA_T_Stat_Combo.e_o;
C_eo = SA_C_Stat_Combo.e_o;
H_eo = SA_H_Stat_Combo.e_o;

figure()
createFitSA_do(C_eo,H_eo,T_eo)

%% Ztest and %% Maximum permissible error test


TestDataset = {T_ep, C_ep, H_ep, T_eo, C_eo, H_eo};
zComp = zeros(6,1);
s_square = zeros(6,1);
e_bar = zeros(6,1);
e_L = zeros(6,1);
e_S = zeros(6,1);
zResult = cell(6,1);
meResult = cell(6,1);
delta_avg = [3, 3, 3, 0.5, 0.5, 0.5];
delta_max = [10, 10, 10, 1, 1, 1];
meComp = zeros(6,1);


for itr1=1:1:length(TestDataset)
    N = length(TestDataset{itr1});
    e_bar(itr1,1) = mean(TestDataset{itr1});
    s_square(itr1,1) =  sum((TestDataset{itr1} - e_bar(itr1,1)).^2)/(N-1);
    zComp(itr1,1) = (e_bar(itr1,1) - delta_avg(itr1)) / sqrt(s_square(itr1,1)/N);
    Z_alpha = 1.6449;
    if zComp(itr1,1) > Z_alpha
        zResult{itr1,1} = 'fail';
    else
        zResult{itr1,1} = 'pass';
    end
    out  = sprintf("Z test: Value = %0.2f \t Result = %s \n", zComp(itr1,1), zResult{itr1,1});
    disp(out)
    
    e_L(itr1,1) = max(TestDataset{itr1});
    e_S(itr1,1) = min(TestDataset{itr1});
    meComp(itr1,1) = (delta_max(itr1) - e_L(itr1,1)) / (e_L(itr1,1)-e_S(itr1,1));
    if meComp(itr1,1) < 0.0526
        meResult{itr1, 1} = 'fail';
    else
        meResult{itr1,1} = 'pass';
    end
    out2  = sprintf("Max error test: Value = %0.2f \t Result = %s \n", meComp(itr1,1), meResult{itr1,1});
    disp(out2)
    
end







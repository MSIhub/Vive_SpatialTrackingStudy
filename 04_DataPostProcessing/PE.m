clear; close all; clc;

load('./0_Tracker/1_PrecisionEvaluation/Results/PE_T_Stat.mat');
load('./1_Controller/1_PrecisionEvaluation/Results/PE_C_Stat.mat');
load('./2_HMD/1_PrecisionEvaluation/Results/PE_H_Stat.mat');

T_dp = PE_T_Stat_Combo.d_p;
C_dp = PE_C_Stat_Combo.d_p;
H_dp = PE_H_Stat_Combo.d_p;

% % CDF
figure()
createFitPE_dp(T_dp,C_dp,H_dp)

T_do = PE_T_Stat_Combo.d_o;
C_do = PE_C_Stat_Combo.d_o;
H_do = PE_H_Stat_Combo.d_o;

figure()
createFitPE_do(C_do,H_do,T_do)

%% Ztest and %% Maximum permissible error test


TestDataset = {T_dp, C_dp, H_dp, T_do, C_do, H_do};
zComp = zeros(6,1);
s_square = zeros(6,1);
e_bar = zeros(6,1);
e_L = zeros(6,1);
e_S = zeros(6,1);
zResult = cell(6,1);
meResult = cell(6,1);
delta_max = [10, 10, 10, 1, 1, 1];
meComp = zeros(6,1);


for itr1=1:1:length(TestDataset)
    N = length(TestDataset{itr1});
    e_bar(itr1,1) = mean(TestDataset{itr1});
    if itr1 <= 3
        delta_avg = 1; %1 mm
    else
        delta_avg = 0.5; % 0.5 deg
    end
    s_square(itr1,1) =  sum((TestDataset{itr1} - e_bar(itr1,1)).^2)/(N-1);
    zComp(itr1,1) = (e_bar(itr1,1) - delta_avg) / sqrt(s_square(itr1,1)/N);
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







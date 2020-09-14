clear; close all; clc;

T = load('./0_Tracker/3_DynamicAnalysis/Results/DA_T_V1_5.mat');
C = load('./1_Controller/3_DynamicAnalysis/Results/DA_C_V1_5.mat');
H = load('./2_HMD/3_DynamicAnalysis/Results/DA_H_V1_5.mat');

T_ep = T.errorStat.e_p;
C_ep = C.errorStat.e_p;
H_ep = H.errorStat.e_p;

% % CDF
figure()
createFitDA_dp(T_ep,C_ep,H_ep)

T_eo = T.errorStat.e_o;
C_eo = C.errorStat.e_o;
H_eo = H.errorStat.e_o;

figure()
createFitDA_do(C_eo,H_eo,T_eo)


% Ztest and %% Maximum permissible error test


TestDataset = {T_ep, C_ep, H_ep, T_eo, C_eo, H_eo};
zComp = zeros(6,1);
s_square = zeros(6,1);
e_bar = zeros(6,1);
e_L = zeros(6,1);
e_S = zeros(6,1);
zResult = cell(6,1);
meResult = cell(6,1);
PLT = zeros(6,1);
delta_avg = [99.65/2, 117/2, 195/2, 2, 2, 2];
delta_max = 1.5 * delta_avg;
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
    
    % Percentage loss of tracking
    PLT(itr1,1) = (numel(find((TestDataset{itr1} > delta_max(itr1))== 1)) / N) * 100;
    
end



%% PLotting the percentage loss for Tracker and COntroller

PLT_C = load('PLT_C.mat');
PLT_T = load('PLT_T.mat');

PLT_C = cell2mat(PLT_C.PLT_int);
PLT_T = cell2mat(PLT_T.PLT_int);
figure()
hold on;
g1 = bar(PLT_T,'histc');
g2 = bar(PLT_C,'histc');
hold off;
set(gca, 'XTick',[1,2,3,4,5,6,7,8,9,10,11] );
set(gca, 'XTickLabel', {0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100});
grid on;
g1.FaceAlpha = 0.9;
g2.FaceAlpha = 0.9;
g2.FaceColor = [0.8500 0.3250 0.0980];
g1.FaceColor = [0.9290 0.6940 0.1250];
FontSize = 9;
LegText = {'Tracker', 'Controller'};
xlabel('Velocity [mm/s]');
ylabel('Percentage Loss in Tracking (%)');
legend(LegText,'Orientation', 'vertical', 'FontSize', FontSize,'FontName', 'CMU Serif','Interpreter','latex');
set(gca, 'FontName', 'CMU Serif','fontweight','bold','FontSize',FontSize,'TickLabelInterpreter','latex');
set(gcf, 'Units', 'centimeters','Position',  [11.101916666666666,9.800166666666668,9.609666666666667,6.815666666666667],...
    'InnerPosition', [10.10192,9.800166666666668,9.609666666666667,6.815666666666667],...
    'OuterPosition', [10.932583333333334,9.630833333333333,9.948333333333334,8.974666666666666]);
% set(gcf,'Renderer', 'painters', 'RendererMode', 'manual');

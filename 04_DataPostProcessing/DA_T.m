clear; close all; clc;


% velRepo = ["V1_5"];

velRepo = ["V1_0", "V0_5", "V0_25", "V0_2", "V0_185", "V0_175", "V0_15", "V0_135", "V0_125", "V0_1", "V0_075", "V0_050", "V0_025", "V0_010"];
% velName = ["SS1","SM1", "SF1", "PS1", "PM1", "PF1", "PM2", "PF2"];

for itr0 =1:1:length(velRepo)
    velName = velRepo(itr0);
    T = load(['./0_Tracker/3_DynamicAnalysis/Results/DA_T_',char(velName),'.mat']);
    T_ep = T.errorStat.e_p;
    T_eo = T.errorStat.e_o;
    T_vel = T.vel;
    % Saving variable for CDF
    fieldName = char(velName);
    tep.(fieldName) = T_ep;
    teo.(fieldName) = T_eo;
    tvel.(fieldName)  = T_vel;
    % Ztest and %% Maximum permissible error test
    TestDataset = {T_ep, T_eo};
    zComp = zeros(2,1);
    s_square = zeros(2,1);
    e_bar = zeros(2,1);
    e_L = zeros(2,1);
    e_S = zeros(2,1);
    zResult = cell(2,1);
    meResult = cell(2,1);
    PLT = zeros(2,1);
    delta_avg = [99.65/2, 2];
    delta_max = 1.5 * delta_avg;
    meComp = zeros(2,1);
    
    
    for itr1=1:1:length(TestDataset)
        N = length(TestDataset{itr1});
        e_bar(itr1,1) = mean(TestDataset{itr1});
        s_square(itr1,1) =  sum((TestDataset{itr1} - e_bar(itr1,1)).^2)/(N-1);
        zComp(itr1,1) = (e_bar(itr1,1) - delta_avg(itr1)) / sqrt(s_square(itr1,1)/N);
        Z_alpha = 1.6449;
        if zComp(itr1,1) > Z_alpha
            zResult{itr1,1} = '\textit{R}';
        else
            zResult{itr1,1} = 'A';
        end
        
        e_L(itr1,1) = max(TestDataset{itr1});
        e_S(itr1,1) = min(TestDataset{itr1});
        meComp(itr1,1) = (delta_max(itr1) - e_L(itr1,1)) / (e_L(itr1,1)-e_S(itr1,1));
        if meComp(itr1,1) < 0.0526
            meResult{itr1, 1} = '\textit{R}';
        else
            meResult{itr1,1} = 'A';
        end
        % Percentage loss of tracking
        PLT(itr1,1) = (numel(find((TestDataset{itr1} > delta_max(itr1))== 1)) / N) * 100;
        if itr1 == 1
            str0 = "\multirow{2}{*}";
            str = "\\ \cline{3-11}";
            out3  = sprintf(" %s ->\t &\t %s \t &\t %s \t &\t %s{%.4f}\t %s", char(velName),zResult{itr1,1},meResult{itr1,1},str0,PLT(itr1,1) ,str);
        else
            str = "\\ \hline";
            out3 = sprintf(" %s ->\t  \t \t&\t %s &\t \t %s \t &\t \t%s", char(velName), zResult{itr1,1},meResult{itr1,1},str);
        end
        disp(out3)
        
    end
    
end

%% Prepare figure
clf;
hold on;
LegHandles = []; LegText = {};
LineWidth = 1;
FontSize = 9;
set(gca, 'FontName', 'CMU Serif','fontweight','bold','FontSize',FontSize,'TickLabelInterpreter','latex');
set(gcf, 'Units', 'centimeters','Position',  [24.60625,19.596805555555555,9.68375,7.196666666666665], 'InnerPosition', [24.60625,19.596805555555555,9.68375,7.196666666666665], 'OuterPosition', [24.412222222222223,19.402777777777775,10.071805555555553,9.507361111111113]);
set(gcf,'Renderer', 'painters', 'RendererMode', 'manual');
fields = fieldnames(tep);
legendName = ["$ V_{0.135}$ ", "$V_{0.125}$", "$V_{0.1}$", "$V_{0.075}$", "$V_{0.050}$", "$V_{0.025}$", "$V_{0.010}$",];
for itr2 =8:1:length(fields)
    % --- Plot data originally in dataset "Tracker"
    [CdfY,CdfX] = ecdf(tep.(fields{itr2}),'Function','cdf');  % compute empirical function
    hLine = stairs(CdfX,CdfY,'LineWidth',LineWidth);
    xlabel('Position error [mm]');
    ylabel('Cumulative probability')
    LegHandles(end+1) = hLine;
    LegText{end+1} = legendName{itr2-7};
end

% Create grid where function will be computed
XLim = get(gca,'XLim');
XLim = XLim + [-1 1] * 0.01 * diff(XLim);
XGrid = linspace(XLim(1),XLim(2),100);
% Adjust figure
box on;
hold off;
grid on;

% Create legend from accumulated handles and labels
hLegend = legend(LegHandles,LegText,'Orientation', 'vertical', 'FontSize', FontSize);
set(hLegend,'Units','normalized');
Position = get(hLegend,'Position');
Position(1:2) = [0.68999,0.696429];
set(hLegend,'Interpreter','latex','Position',Position);
xlim([0 delta_max(1)])

% Prepare figure
clf;
hold on;
LegHandles = []; LegText = {};
LineWidth = 1;
FontSize = 9;
set(gca, 'FontName', 'CMU Serif','fontweight','bold','FontSize',FontSize,'TickLabelInterpreter','latex');
set(gcf, 'Units', 'centimeters','Position',  [24.60625,19.596805555555555,9.68375,7.196666666666665], 'InnerPosition', [24.60625,19.596805555555555,9.68375,7.196666666666665], 'OuterPosition', [24.412222222222223,19.402777777777775,10.071805555555553,9.507361111111113]);
set(gcf,'Renderer', 'painters', 'RendererMode', 'manual');
fields = fieldnames(teo);
legendName = ["$ V_{0.135}$ ", "$V_{0.125}$", "$V_{0.1}$", "$V_{0.075}$", "$V_{0.050}$", "$V_{0.025}$", "$V_{0.010}$",];
for itr2 =8:1:length(fields)
    % --- Plot data originally in dataset "Tracker"
    [CdfY,CdfX] = ecdf(teo.(fields{itr2}),'Function','cdf');  % compute empirical function
    hLine = stairs(CdfX,CdfY,'LineWidth',LineWidth);
    xlabel('Orientation error [deg$^{\circ}$]');
    ylabel('Cumulative probability')
    LegHandles(end+1) = hLine;
    LegText{end+1} = legendName{itr2-7};
end

% Create grid where function will be computed
XLim = get(gca,'XLim');
XLim = XLim + [-1 1] * 0.01 * diff(XLim);
XGrid = linspace(XLim(1),XLim(2),100);
% Adjust figure
box on;
hold off;
grid on;

% Create legend from accumulated handles and labels
hLegend = legend(LegHandles,LegText,'Orientation', 'vertical', 'FontSize', FontSize);
set(hLegend,'Units','normalized');
Position = get(hLegend,'Position');
Position(1:2) = [0.68999,0.696429];
set(hLegend,'Interpreter','latex','Position',Position);
xlim([0 delta_max(2)])


%% Vel vs e_p

clearvars -except tvel tep teo delta_max
V = [];
E = [];
tfields = fieldnames(tvel);
for itr1 = 1:1:length(tfields)
    V = [V; tvel.(tfields{itr1})] ;
    E = [E; tep.(tfields{itr1})];
end
% V2 = V((V < 250)== 1);
% E2 = E((V < 250)== 1);
% scatter(V2,E2,'.')
% ylim([0 delta_max(1)])

% interval
interval = 100;
upperBound = 1000;
count = 1;
max_count = floor(upperBound/interval);
PLT_int = cell(max_count,1);
V_int = cell(max_count,1);
E_int = cell(max_count,1);

for itr2 = 0:interval:(upperBound-interval)
    ind = find((V > itr2 & V < itr2+interval) == 1);
    PLT_int{count,1} = (numel(find((E(ind,:) > delta_max(1))== 1)) / size(E(ind,:),1)) * 100;
    V_int{count,1} = V(ind,:);
    E_int{count,1} = E(ind,:);
    count = count +1;
end
save PLT_T.mat PLT_int

%
figure()
bg = bar(cell2mat(PLT_int),'histc');
set(gca, 'XTickLabel', 0:interval:upperBound);
% bg.FaceColor = [0.8500 0.3250 0.0980];
% bg.EdgeColor = 'flat';
% grid on;
% FontSize = 9;
% set(gca, 'FontName', 'CMU Serif','fontweight','bold','FontSize',FontSize,'TickLabelInterpreter','latex');
% % set(gcf, 'Units', 'centimeters','Position',  [24.60625,19.596805555555555,9.68375,7.196666666666665], 'InnerPosition', [24.60625,19.596805555555555,9.68375,7.196666666666665], 'OuterPosition', [24.412222222222223,19.402777777777775,10.071805555555553,9.507361111111113]);
% set(gcf,'Renderer', 'painters', 'RendererMode', 'manual');


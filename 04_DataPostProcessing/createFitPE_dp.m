function createFitPE_dp(T_dp,C_dp,H_dp)
%CREATEFIT    Create plot of datasets and fits
%   CREATEFIT(T_DP,C_DP,H_DP)
%   Creates a plot, similar to the plot in the main distribution fitter
%   window, using the data that you provide as input.  You can
%   apply this function to the same data you used with dfittool
%   or with different data.  You may want to edit the function to
%   customize the code and this help message.
%
%   Number of datasets:  3
%   Number of fits:  0
%
%   See also FITDIST.

% This function was automatically generated on 04-Sep-2020 13:46:25

% Data from dataset "Tracker":
%    Y = T_dp

% Data from dataset "Controller":
%    Y = C_dp

% Data from dataset "HMD":
%    Y = H_dp

% Force all inputs to be column vectors
T_dp = T_dp(:);
C_dp = C_dp(:);
H_dp = H_dp(:);

% Prepare figure
clf;
hold on;
LegHandles = []; LegText = {};


str = {'T: F(1) = 0.941552' 'C: F(1) = 0.94578'  'H: F(0.74) = 1'};
FontSize = 9;
LineWidth = 1.2;
dim = [.55 .4 .27 .17];
annotation('textbox',dim,'String',str,'FontName', 'CMU Serif','FontSize',FontSize, 'fontweight','bold','FitBoxToText','on','interpreter','latex');
set(gca, 'FontName', 'CMU Serif','fontweight','bold','FontSize',FontSize,'TickLabelInterpreter','latex');
set(gcf, 'Units', 'centimeters','Position',  [24.60625,19.596805555555555,9.68375,7.196666666666665], 'InnerPosition', [24.60625,19.596805555555555,9.68375,7.196666666666665], 'OuterPosition', [24.412222222222223,19.402777777777775,10.071805555555553,9.507361111111113]);
set(gcf,'Renderer', 'painters', 'RendererMode', 'manual');

% --- Plot data originally in dataset "Tracker"
[CdfY,CdfX] = ecdf(T_dp,'Function','cdf');  % compute empirical function
hLine = stairs(CdfX,CdfY,'Color','r','LineStyle','-', 'LineWidth',LineWidth);
xlabel('Deviation from mean [mm]');
ylabel('Cumulative probability')
LegHandles(end+1) = hLine;
LegText{end+1} = 'Tracker';

% --- Plot data originally in dataset "Controller"
[CdfY,CdfX] = ecdf(C_dp,'Function','cdf');  % compute empirical function
hLine = stairs(CdfX,CdfY,'Color','g','LineStyle','--', 'LineWidth',LineWidth);
xlabel('Deviation from mean [mm]');
ylabel('Cumulative probability')
LegHandles(end+1) = hLine;
LegText{end+1} = 'Controller';

% --- Plot data originally in dataset "HMD"
[CdfY,CdfX] = ecdf(H_dp,'Function','cdf');  % compute empirical function
hLine = stairs(CdfX,CdfY,'Color','b','LineStyle','-.', 'LineWidth',LineWidth);
xlabel('Deviation from mean [mm]');
ylabel('Cumulative probability')
LegHandles(end+1) = hLine;
LegText{end+1} = 'HMD';

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

function createFitSA_do(C_do,H_do,T_do)
%CREATEFIT    Create plot of datasets and fits
%   CREATEFIT(C_DO,H_DO,T_DO)
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

% This function was automatically generated on 04-Sep-2020 14:36:22

% Data from dataset "Controller":
%    Y = C_do

% Data from dataset "HMD":
%    Y = H_do

% Data from dataset "Tracker":
%    Y = T_do

% Force all inputs to be column vectors
C_do = C_do(:);
H_do = H_do(:);
T_do = T_do(:);

% Prepare figure
clf;
hold on;
LegHandles = []; LegText = {};

str = {'T: F(0.5) = 0.515572' 'C: F(0.5) = 0.964805'  'H: F(0.5) = 0.98991'};

FontSize = 9;
LineWidth = 1.2;
dim = [.55 .4 .27 .17];
annotation('textbox',dim,'String',str,'FontName', 'CMU Serif','FontSize',FontSize, 'fontweight','bold','FitBoxToText','on','interpreter','latex');
set(gca, 'FontName', 'CMU Serif','fontweight','bold','FontSize',FontSize,'TickLabelInterpreter','latex');
set(gcf, 'Units', 'centimeters','Position',  [24.60625,19.596805555555555,9.68375,7.196666666666665], 'InnerPosition', [24.60625,19.596805555555555,9.68375,7.196666666666665], 'OuterPosition', [24.412222222222223,19.402777777777775,10.071805555555553,9.507361111111113]);
set(gcf,'Renderer', 'painters', 'RendererMode', 'manual');

% --- Plot data originally in dataset "Tracker"
[CdfY,CdfX] = ecdf(T_do,'Function','cdf');  % compute empirical function
hLine = stairs(CdfX,CdfY,'Color','r','LineStyle','-', 'LineWidth',LineWidth);
xlabel('Orientation Error [deg $^{\circ}$]');
ylabel('Cumulative probability')
LegHandles(end+1) = hLine;
LegText{end+1} = 'Tracker';

% --- Plot data originally in dataset "Controller"
[CdfY,CdfX] = ecdf(C_do,'Function','cdf');  % compute empirical function
hLine = stairs(CdfX,CdfY,'Color','g','LineStyle','--', 'LineWidth',LineWidth);
xlabel('Orientation Error [deg $^{\circ}$]');
ylabel('Cumulative probability')
LegHandles(end+1) = hLine;
LegText{end+1} = 'Controller';

% --- Plot data originally in dataset "HMD"
[CdfY,CdfX] = ecdf(H_do,'Function','cdf');  % compute empirical function
hLine = stairs(CdfX,CdfY,'Color','b','LineStyle','-.', 'LineWidth',LineWidth);
xlabel('Orientation Error [deg $^{\circ}$]');
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
hLegend = legend(LegHandles,LegText,'Orientation', 'vertical', 'Location', 'best', 'FontName', 'CMU Serif','FontSize',FontSize, 'fontweight','bold');
set(hLegend,'Interpreter','latex');

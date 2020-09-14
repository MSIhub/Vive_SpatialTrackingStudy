clear; close all; clc;

startItr = 1;
num_of_path = 10;

for itr1 = startItr:1:num_of_path
    %% Loading files (tracker and comau)
    str1 = ['SA_C_path', num2str(itr1)];
    P = ['F:\OneDrive - unige.it\ViveStudy\3_Experimentation\1_Controller\1_PrecisionEvaluation\RawData\', str1];
    S = dir(fullfile(P,'*.txt'));
    N = {S.name};
    X1 = contains(N,"rawComauData");
    X2 = contains(N,"rawViveDataController");
    filenameComau = fullfile(P,N{X1});
    filenameController = fullfile(P,N{X2});
    filenameHmd = "";
    filenameTracker = "";
    
    
    %% PARAM
    isCalibrationOn = false;
    delimiterV = ",";
    delimiterC = ",";
    resamplingRate = 100;
    
    %###################################################################%%
    %% Loading and post proccesing data for comau and vive
    Comau = comauPP(filenameComau,delimiterC);
    Vive = vivePP(filenameHmd,filenameController,filenameTracker,delimiterV);
    
    %###################################################################%%
    %% Synchronising vive and comau
    %out: point correspondance data V: vive struct, C:comau array
    %%BE CAREFUL OF THE RMOUTLIERS PECENTILE, IT MUST BE TUNED PER DATASET
    [V,C] = syncViveComau(Comau,Vive, resamplingRate, isCalibrationOn);
    
    %% Precision evaluation: Point extraction from the path
    % Extracting 10 points in the first path and use these 10 points to extract
    % their corresponding points in the all the paths
    path1 = load("PathData/SA_C_Path1.txt");
    path1(:,1:3) = path1(:,1:3)*0.001; %mm to m
    % isolate the points separately
    Points = struct();
    Points.P1 = round(path1(1,1:3),4);
    Points.P2 = round(path1(2,1:3),4);
    Points.P3 = round(path1(3,1:3),4);
    Points.P4 = round(path1(4,1:3),4);
    Points.P5 = round(path1(5,1:3),4);
    Points.P6 = round(path1(6,1:3),4);
    Points.P7 = round(path1(7,1:3),4);
    Points.P8 = round(path1(8,1:3),4);
    Points.P9 = round(path1(9,1:3),4);
    Points.P10 = round(path1(10,1:3),4);
    
    %% Make sure to change the device name if not tracker
    pointsinPath = pointsinOnePath(C,V.controller3,Points);
    
    % Saving to mat file
    resultFile = ['Results/', str1, '.mat'];
    save(resultFile, '-struct','pointsinPath');
    
    clearvars -except itr1 num_of_path startItr;
end

close all; clc;
clearvars -except  num_of_path startItr;

% num_of_path = 10;
folderName = 'Results/';
PointsCombined = struct();
PointsCombined.PT1 = struct('V',[],'C',[]);
PointsCombined.PT2 = struct('V',[],'C',[]);
PointsCombined.PT3 = struct('V',[],'C',[]);
PointsCombined.PT4 = struct('V',[],'C',[]);
PointsCombined.PT5 = struct('V',[],'C',[]);
PointsCombined.PT6 = struct('V',[],'C',[]);
PointsCombined.PT7 = struct('V',[],'C',[]);
PointsCombined.PT8 = struct('V',[],'C',[]);
PointsCombined.PT9 = struct('V',[],'C',[]);
PointsCombined.PT10 = struct('V',[],'C',[]);

for itr1 = startItr:1:num_of_path
    clear PointsCombined.P1 PointsCombined.P2 PointsCombined.P3 PointsCombined.P4 PointsCombined.P5 PointsCombined.P6 PointsCombined.P7 PointsCombined.P8 PointsCombined.P9 PointsCombined.P10
    fileName = [folderName, 'SA_C_path', num2str(itr1),'.mat'];
    load(fileName);
    PointsCombined.PT1.V = [PointsCombined.PT1.V; P1.V];              PointsCombined.PT1.C = [PointsCombined.PT1.C; P1.C];
    PointsCombined.PT2.V = [PointsCombined.PT2.V; P2.V];              PointsCombined.PT2.C = [PointsCombined.PT2.C; P2.C];
    PointsCombined.PT3.V = [PointsCombined.PT3.V; P3.V];              PointsCombined.PT3.C = [PointsCombined.PT3.C; P3.C];
    PointsCombined.PT4.V = [PointsCombined.PT4.V; P4.V];              PointsCombined.PT4.C = [PointsCombined.PT4.C; P4.C];
    PointsCombined.PT5.V = [PointsCombined.PT5.V; P5.V];              PointsCombined.PT5.C = [PointsCombined.PT5.C; P5.C];
    PointsCombined.PT6.V = [PointsCombined.PT6.V; P6.V];              PointsCombined.PT6.C = [PointsCombined.PT6.C; P6.C];
    PointsCombined.PT7.V = [PointsCombined.PT7.V; P7.V];              PointsCombined.PT7.C = [PointsCombined.PT7.C; P7.C];
    PointsCombined.PT8.V = [PointsCombined.PT8.V; P8.V];              PointsCombined.PT8.C = [PointsCombined.PT8.C; P8.C];
    PointsCombined.PT9.V = [PointsCombined.PT9.V; P9.V];              PointsCombined.PT9.C = [PointsCombined.PT9.C; P9.C];
    PointsCombined.PT10.V = [PointsCombined.PT10.V; P10.V];           PointsCombined.PT10.C = [PointsCombined.PT10.C; P10.C];
    clear PointsCombined.P1 PointsCombined.P2 PointsCombined.P3 PointsCombined.P4 PointsCombined.P5 PointsCombined.P6 PointsCombined.P7 PointsCombined.P8 PointsCombined.P9 PointsCombined.P10
end

PointsCombined.PT1.V(1,:) = []; PointsCombined.PT1.C(1,:) = [];
PointsCombined.PT2.V(1,:) = []; PointsCombined.PT2.C(1,:) = [];
PointsCombined.PT3.V(1,:) = []; PointsCombined.PT3.C(1,:) = [];
PointsCombined.PT4.V(1,:) = []; PointsCombined.PT4.C(1,:) = [];
PointsCombined.PT5.V(1,:) = []; PointsCombined.PT5.C(1,:) = [];
PointsCombined.PT7.V(1,:) = []; PointsCombined.PT7.C(1,:) = [];
PointsCombined.PT8.V(1,:) = []; PointsCombined.PT8.C(1,:) = [];
PointsCombined.PT9.V(1,:) = []; PointsCombined.PT9.C(1,:) = [];
PointsCombined.PT10.V(1,:) = []; PointsCombined.PT10.C(1,:) = [];

resultFile = 'Results/PointsCombined.mat';
save(resultFile, '-struct','PointsCombined');

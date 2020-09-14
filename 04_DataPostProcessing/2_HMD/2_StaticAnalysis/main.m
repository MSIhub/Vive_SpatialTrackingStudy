clear; close all; clc;


%% Loading files (tracker and comau)
P = 'F:\OneDrive - unige.it\ViveStudy\3_Experimentation\2_HMD\2_StaticAnalysis\RawData\';
S = dir(fullfile(P,'*.txt'));
N = {S.name};
X1 = contains(N,"rawComauData");
X2 = contains(N,"rawViveDataHMD");
filenameComau = fullfile(P,N{X1});
filenameHmd = fullfile(P,N{X2});
filenameTracker = "";
filenameController = "";

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

%% Point extraction from the path
% Extracting 10 points in the first path and use these 10 points to extract
% their corresponding points in the all the paths
path = load("PathData/SA.txt");
path(:,1:3) = path(:,1:3)*0.001; %mm to m
% isolate the points separately
Points = struct();
for itr2 = 1:1:length(path)
    Points.(['P',num2str(itr2)]) = round(path(itr2,1:3),4);
end
%% Make sure to change the device name if not tracker
pointsinPath = pointsinOnePath(C,V.hmd,Points);

% Saving to mat file
resultFile = 'Results/SA_H.mat';
save(resultFile,'-struct','pointsinPath');




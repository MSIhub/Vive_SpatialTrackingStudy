%%This script is an example for post processing comau and vive data
%%"ASSUMING THAT ALL THE FILES FROM VIVE HAS THE SAME SIZE OF DATA AND SAME
%%TIMESTAMP"
clear; close all; clc;

%% ################## INPUT PARAMETERS HERE ###############################%%
resamplingRate = 100;
isCalibrationOn = true; % calibration mode true filters the outliers, if false filter is not done as we want to evaluate the actual data
choice_of_algorithm = 1;% choice_of_algorithm -> 1: cashbaugh (default); 2: Arun; 3: umyema
visualizeData = true;

% calibfile = 'calibrationFiles/1580926005006601300.mat'; 
% Comau Filenames
filenameComau = "Data\Calibration\rawComauData_1595395859341942500.txt"; % HUGE FILE RUN TIME WARNING
delimiterC = ",";
VisualiseRawDataComau = true;

% Vive Filenames
filenameHmd = "";   
filenameController = "";
filenameTracker = "Data\Calibration\rawViveDataTracker_1595395859341962700.txt";
delimiterV = ",";


dp = vcdp();
%###################################################################%%

%% Loading and post proccesing data for comau and vive

rawCarVive = dp.vivePP(filenameHmd,filenameController,filenameTracker,delimiterV);
nonDuplicateDataComau = dp.comauPP(filenameComau,delimiterC);


%###################################################################%%
%% Synchronising vive and comau
%out: point correspondance data M: struct, N:comau array
fields = fieldnames(rawCarVive);
[M,N] = dp.syncViveComau(nonDuplicateDataComau,rawCarVive, resamplingRate, isCalibrationOn);
%num_of_data = size(M,1);
%###################################################################%%
%% Run calibration cashbugh algorithm
%Out: Transformation matrix for the calibrated space
% M  % Data frame that has to be transformed (from) % N  % Reference Data frame (to)
% choice_of_algorithm -> 1: cashbaugh (default); 2: Arun; 3: umyema
transformData = struct();
if isCalibrationOn
    for i = 1:1:length(fields)
        [T,AngleOffset, O] = dp.calibrateViveComau(M.(fields{i}),N,choice_of_algorithm,filenameComau);
        transformData.(fields{i}).T = T;
        transformData.(fields{i}).AngleOffset = AngleOffset;
        transformData.(fields{i}).O = O;
    end
end
%% Transforming the data collected in data frame M to data frame N and storing in O
if ~isCalibrationOn
    load(calibfile); disp('calib file loaded');
    if (exist('T','var') && exist('AngleOffset','var'))
        for j = 1:1:length(fields)
            [O] = dp.transformViveComau(M.(fields{j}), T, AngleOffset);
            transformData.(fields{j}).O = O;
            transformData.(fields{j}).T = T;
            transformData.(fields{j}).AngleOffset = AngleOffset;
        end
    else
        error('Calibration data T or AngleOffset missing, ensure that calibration is run');
    end
end

%% Saving the three output varibles to the mat file
%%----Refactoring the variable to be secure to changes when saving----%%
viveData = M.(fields{1});
comauData = N;
transformedViveData = transformData.(fields{1}).O;
T = transformData.(fields{1}).T;
AngleOffset = transformData.(fields{1}).AngleOffset;

%%----Extracting the timestamp from the filename to match filename and mat file----%%
ffff = regexp(filenameComau,'[0-9]','match');
folderName = "results/";
newStr = join(ffff,"");
newStr = newStr.append("_CashV2.mat");
save(folderName.append(newStr),'comauData','viveData','transformedViveData', 'T', 'AngleOffset' );
fprintf("Result data are saved in '%s' \n", folderName.append(newStr))

%% Test the calibration matrix for percentage error
%%----Find the root mean squared error----%%

% en =1+ round((num_of_data).*rand(1,1)); % Randomly selecting a value to avoid bias
err =transformedViveData - comauData; % Change if the order of A and B is to be modified
rmse = rms(err,1);
fprintf("Root Mean Square Deviation or calibration = %d\n", rmse);
% Out: percentage of error in calibration


%% Visualisation
if visualizeData == true
    Comau = N;
    for itr7 = 1:1:length(fields)
        Vive = M.(fields{itr7});
        O = transformData.(fields{itr7}).O;
        figure(itr7)
        scatter3(Vive(:,2),Vive(:,3),Vive(:,4), 'ro'); hold on;
        scatter3(Comau(:,2),Comau(:,3),Comau(:,4),'b*'); hold on;
        scatter3(O(:,2),O(:,3),O(:,4),'go'); hold on;
        axis tight;
        axis equal;
        title("Translational 3D trajectory Comau and " + fields{itr7});
        legend('Vive', 'Comau', 'Transformed VivetoComau')
        %         MyText = sprintf("Distance \n Comau = %f m\n Vive = %f m \n DistError = %f mm", distComau, distVive.(fields{itr7}),distErrorMM);
        %         annotation('textbox', [0.75, 0.4, 1, 0.2], 'string', MyText)
        %
        figure(itr7+1)
        scatter(Vive(:,1),Vive(:,2), 'ro'); hold on;
        scatter(Comau(:,1), Comau(:,2),'b*'); hold on;
        scatter(O(:,1),O(:,2),'go'); hold on;
        legend('Vive', 'Comau', 'Transformed VivetoComau')
        title('Position in X-Axis: trajectory')
        ylabel('x axis [m]')
        xlabel('timestamp [seconds]')
        
        figure(itr7+2)
        scatter(Vive(:,1),Vive(:,3), 'ro'); hold on;
        scatter(Comau(:,1), Comau(:,3),'b*'); hold on;
        scatter(O(:,1),O(:,3),'go'); hold on;
        legend('Vive', 'Comau', 'Transformed VivetoComau')
        title('Position in Y-Axis: trajectory')
        ylabel('y axis [m]')
        xlabel('timestamp [seconds]')
        
        
        figure(itr7+3)
        scatter(Vive(:,1),Vive(:,4), 'ro'); hold on;
        scatter(Comau(:,1), Comau(:,4),'b*'); hold on;
        scatter(O(:,1),O(:,4),'go'); hold on;
        legend('Vive', 'Comau', 'Transformed VivetoComau')
        title('Position in Z-Axis: trajectory')
        ylabel('z axis [m]')
        xlabel('timestamp [seconds]')
        
        figure(itr7+4)
        polarscatter(deg2rad(Vive(:,5)),Vive(:,1), 'ro'); hold on;
        polarscatter(deg2rad(Comau(:,5)), Comau(:,1),'b*'); hold on;
        polarscatter(deg2rad(O(:,5)),O(:,1),'go'); hold on;
        legend('Vive', 'Comau', 'Transformed VivetoComau')
        title('Orientation in Z (ZYZ conv): trajectory')
        
        figure(itr7+5)
        polarscatter(deg2rad(Vive(:,6)),Vive(:,1), 'ro'); hold on;
        polarscatter(deg2rad(Comau(:,6)), Comau(:,1),'b*'); hold on;
        polarscatter(deg2rad(O(:,6)),O(:,1),'go'); hold on;
        legend('Vive', 'Comau', 'Transformed VivetoComau')
        title('Orientation in Y (ZYZ conv): trajectory')
        
        figure(itr7+6)
        polarscatter(deg2rad(Vive(:,7)),Vive(:,1), 'ro'); hold on;
        polarscatter(deg2rad(Comau(:,7)), Comau(:,1),'b*'); hold on;
        polarscatter(deg2rad(O(:,7)),O(:,1),'go'); hold on;
        legend('Vive', 'Comau', 'Transformed VivetoComau')
        title('Orientation in Zdash (ZYZ conv): trajectory')
        
    end
end

clear; close all; clc;
%% Loading files (tracker and comau)
FLOAT_PRECISION = 8;
velName = "HT";
repoName = ["SS1"]%, "YO1", "XO2", "YO2", "XO3", "YO3"];
for itr1 = 1:1:length(repoName)
    resultFile = ['Results/DA_T_',char(velName),'_',char(repoName(itr1)),'.mat'];
    P = ['F:\OneDrive - unige.it\ViveStudy\3_Experimentation\0_Tracker\3_DynamicAnalysis\RawData\',char(velName),'\',char(repoName(itr1))];
    
    S = dir(fullfile(P,'*.txt'));
    N = {S.name};
    X1 = contains(N,"rawComauData");
    X2 = contains(N,"rawViveDataTracker5");
    X3 = contains(N,"rawViveDataTracker6");
    filenameComau = fullfile(P,N{X1});
    filenameTracker5 = fullfile(P,N{X2});
    filenameTracker6 = fullfile(P,N{X3});
    filenameHmd = "";
    filenameController = "";
    %% PARAM
    isCalibrationOn = false;
    delimiterV = ",";
    delimiterC = ",";
    resamplingRate = 100;
    %###################################################################%%
    %% Loading and post proccesing data for comau and vive
    Comau = comauPP(filenameComau,delimiterC);
    Vive = vivePP(filenameHmd,filenameController,filenameTracker5, filenameTracker6, delimiterV);
    %###################################################################%%
    %% Synchronising vive and comau
    %out: point correspondance data V: vive struct, C:comau array
    [V,C] = syncViveComau(Comau,Vive, resamplingRate, isCalibrationOn);
    %% Tranforming Vive tracker left to Vive tracker right (5 to 6)
    left = V.tracker5;
    right = V.tracker6;
    numData = length(left);
    nT = zeros(numData,1);%norm of translation vector for the tranformed left to right
    theta = zeros(numData, 1); %angle of rotation for transformed left to right
    timestamp = zeros(numData, 1);
    for itr2 = 1:1:numData
        [H, t, theta1, T] = transformViveData(left(itr2,:),right(itr2,:));
        rotmCheck = sum(sum(abs(round(H(1:3,1:3) * transpose(H(1:3, 1:3)), 4) - eye(3,3))));
        if ( rotmCheck > 0.001 && rotmCheck < -0.001)
            error('rotation matrix error');
        end
        nT(itr2,1) = norm(T);
        theta(itr2,1) = theta1;
        timestamp(itr2,1) = t;
    end
    vel = C(:,8);
    % Saving to mat file
    save(resultFile,'timestamp', 'nT', 'theta', 'vel');
end


%% Plots
figure()
hold on;
scatter3(V.tracker5(:,5),V.tracker5(:,13),V.tracker5(:,9));
scatter3(V.tracker6(:,5),V.tracker6(:,13),V.tracker6(:,9));
axis equal

% Vcenter = [(V.tracker5(:,5) - V.tracker6(:,5)) , ((V.tracker5(:,13) - V.tracker6(:,13))), ...
%     ((V.tracker5(:,9) - V.tracker6(:,9)))];
% figure()
% hold on;
% scatter3(Vcenter(:,1), Vcenter(:,2), Vcenter(:,3));
% axis equal
% 
% figure()
% hold on;
% plot(V.tracker5(:,5),'b')
% plot(V.tracker6(:,5),'r')
% 
% 
% figure()
% hold on;
% plot(V.tracker5(:,9),'b')
% plot(V.tracker6(:,9),'r')
% 
% 
% figure()
% hold on;
% plot(V.tracker5(:,13),'b')
% plot(V.tracker6(:,13),'r')


% CALculate velocity
% tdiff  = centralisedNumericalDiff(timestamp);
% vel  = centralisedNumericalDiff(nT)./tdiff;
% [vel, idx] = rmoutliers(vel, 'percentiles',[3 97]);

% timestamp = timestamp(idx==0);
% nT = nT(idx==0);
% theta = theta(idx==0);

%
% figure()
% plot(timestamp, nT);
%
% figure()
% plot(timestamp, theta);
% %
% % [M, P, C] = mode(round(nT,4))
% % [M1, P1, C1] = mode(round(theta,4))
%
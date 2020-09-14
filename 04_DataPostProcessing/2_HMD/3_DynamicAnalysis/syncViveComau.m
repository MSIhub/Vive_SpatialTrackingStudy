function [V,C] = syncViveComau(rawComau,rawVive, resamplingRate)
%syncViveComau Syncronising the collected exp data from vive and comau
% checking the duration of data collected: ideally time duration for vive is little higher than comau but if it is a lot(more than 45 seconds) then vive did not collected data
% Synchronizing data
% TIME INPUT: milliseconds
%   Finding the index of the starting timestamp matching
%   Matching the start time
%   Resampling synchronised data
%   Removing 2 seconds from top and bottom
%
if nargin<3
    resamplingRate = 100;
end
%% checking the duration of data collected

timeDurationComau = (rawComau(end,1) - rawComau(1,1)); 
disp('time duration for Comau');
disp(timeDurationComau);

fields = fieldnames(rawVive);
timeDurationVive = struct();
for itr1= 1:1:length(fields)
    timeDurationVive.(fields{itr1}) =  (rawVive.(fields{itr1})(end,1) - rawVive.(fields{itr1})(1,1)); % nano to milli
    disp('time duration for Vive');
    disp(timeDurationVive.(fields{itr1}));
    timediff = (timeDurationVive.(fields{itr1})) - timeDurationComau;
    if (abs(timediff)) > 4.5*1e4
        sprintf('Time differnce between Vive and Comau is greater than 45 seconds: %0.6f', timediff);
    end
end

%% Synchronizing data

fields = fieldnames(rawVive);
syncViveData = struct();
flagSyncVive = true;
for itr2= 1:1:length(fields)
    %%----Finding the index of the starting timestamp matching----%%
    A = round(rawComau(:,1)*10); % sync at 10th ms
    B = round(rawVive.(fields{itr2})(:,1)*10);
    
    if size(A,1)>size(B,1)
        B(size(B,1):size(A,1),:)= -11111111;
    elseif size(A,1)<size(B,1)
        A(size(A,1):size(B,1),:) = -11111111;
    end
    
    [~,C1] = ismember(B,A);
    
    [ind] = find(C1~=0);
    matind = C1(ind);
    %%----Matching the start time----%%
    syncComauData = rawComau(matind(1):end,:);
    syncViveData.(fields{itr2}) = rawVive.(fields{itr2})(ind(1):end,:);
end

if(length(fields) < 2 || syncViveData.(fields{1})(1,1)*10 == syncViveData.(fields{2})(1,1)*10)
    flagSyncVive = false;
end

if flagSyncVive
    %clear syncComauData;
      %%----Finding the index of the starting timestamp matching----%%
    A = round(syncViveData.(fields{1})(:,1)*10); % Nano to milli
    B = round(syncViveData.(fields{2})(:,1)*10); % Nano to milli
    
    if size(A,1)>size(B,1)
        B(size(B,1):size(A,1),:)= -11111111;
    elseif size(A,1)<size(B,1)
        A(size(A,1):size(B,1),:) = -11111111;
    end
    
    [~,C1] = ismember(B,A);
    
    [ind] = find(C1~=0);
    matind = C1(ind);
    %%----Matching the start time----%%
    syncViveData.(fields{1})= syncViveData.(fields{1})(matind(1):end,:);
    syncViveData.(fields{2}) = syncViveData.(fields{2})(ind(1):end,:);
    %comauMatchIdx = find(round(rawComau(:,1)*10)== round(syncViveData.(fields{1})(1,1)*10));
    %syncComauData = rawComau(comauMatchIdx(1):end,:);
end

%----------------------------------------------------------------------%

%% Resampling synchronised data----%%
%%----vive----%%
resampledDataVive = struct();
for itr3= 1:1:length(fields)
    [rdv,rtv] = resamplingRawData(syncViveData.(fields{itr3}),resamplingRate);
    resampledDataVive.(fields{itr3})(:,1) = rtv;
    resampledDataVive.(fields{itr3})(:,2:13) = rdv;
end

%%----Comau----%%
[rdc, rtc] = resamplingRawData(syncComauData, resamplingRate);
resampledDataComau(:,1) = rtc;
resampledDataComau(:,2:8) = rdc;


%% ----Removing the extra data----%%

tmp = zeros(size(fields));
for itr5 = 1:1:length(fields)
    tmp(itr5,1) = size(resampledDataVive.(fields{itr5}),1);
end

viveEndLen = min(tmp);

if size(resampledDataComau,1) <= viveEndLen
    endLen = size(resampledDataComau,1);
else
    endLen = viveEndLen;
end

Comau = resampledDataComau(1:endLen,:);
Vive = struct();
for itr4 = 1:1:length(fields)
    Vive.(fields{itr4})=resampledDataVive.(fields{itr4})(1:endLen,:);
end


%%----Calibration points----%%
V = Vive;
C = Comau; % Reference Data frame (to)
end

%----------------------------------------------------------------------%
% %% ---- Removing the outlier and it corresponding value to avoid overfitting
% outliersIndex = zeros(length(Comau),1);
% for itr5 = 1:1:length(fields)
%     for itr6 = 2:1:13 % Checking outliers only in positon
%         [~,TF_v] = rmoutliers(Vive.(fields{itr5})(:,itr6), 'percentiles',[0.5 99.5]);
%         outliersIndex = outliersIndex + TF_v;
%     end
% end
% for itr7 = 1:1:length(fields)
%     Vive.(fields{itr7}) = Vive.(fields{itr7})(outliersIndex==0,:);
%     Vive.(fields{itr7})(:,1)=Vive.(fields{itr7})(:,1) - Vive.(fields{itr7})(1,1);
% end
% Comau = Comau(outliersIndex==0,:);
% Comau(:,1) = Comau(:,1) - Comau(1,1);

%----------------------------------------------------------------------%

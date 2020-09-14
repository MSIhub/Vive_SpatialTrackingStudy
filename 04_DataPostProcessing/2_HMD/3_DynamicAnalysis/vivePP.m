function [Vive] = vivePP(filenameHmd,filenameController,filenameTracker,delimiter)
%%vivePP This script for loading and visualising raw extracted from
% OpenVR scripts and clientComau application through TCP/IP connection
% author: @msihub , mohamedsadiq.ikbal@edu.unige.it

%%--------------------------------------------------------------------------%%
%RAW DATA FORMAT FROM openVR:  [ID AbsTimestamp ViveClock t00 t01 t02 t03 t10 t11 t12 t13 t20 t21 t22 t23] %
%UNITS:                        [integer nanoseconds nanoseconds relativeFloatUnits ]
%Delimiter: comma
%T = [t00 t01 t02 t03
%     t10 t11 t12 t13
%     t20 t21 t22 t23]
% The data collection is done every 9 milliseconds thus we round up the
% data input to the 10th decimal of milliseconds
%%--------------------------------------------------------------------------%%
% if nargin < 5
%     error("Number of arguments must be four even if some files are not present");
% end

flnh = filenameHmd;
flnc = filenameController;
flnt = filenameTracker;

%%-------------------------------------------------------------------------%%
%If the file is empty delete the file


%% Import text file to the struct in the following order
%------------ STRUCT
% rawDataVive:
%      hmd
%      controller1
%      controller2
%      tracker1
%      .
%      .
%      .
%      trackern

%------------------------

rawVive = struct();

% HMD
if isfile(flnh)
    rawVive.hmd = importdata(flnh,delimiter);
else
    disp("HMD file is not available, check directory for file.")
end

% Controller (seperate Right and left)
if isfile(flnc)
    vr_controllers_raw = importdata(flnc,delimiter);
    if (isempty(vr_controllers_raw))
        disp("VR controllers file is empty, check whether the devices were connected")
    else
        controllerIDs = unique(vr_controllers_raw(:,1));
        for itr1 = 1:1:length(controllerIDs)
            fld = strcat("controller",string(controllerIDs(itr1)));
            rawVive.(fld) = vr_controllers_raw(vr_controllers_raw(:,1) ==  (controllerIDs(itr1)),:);
        end
    end
else
    disp("Controller file is not available, check directory for file.")
end


%Tracker (handling multiple trackers)
if isfile(flnt)
    vr_trackers_raw5 = importdata(flnt,delimiter);
    % Extract and organise data from the file
    if (isempty(vr_trackers_raw5))
        disp("VR trackers file is empty, check whether the devices were connected. If no controllers are connected, the data will be in controller file")
    else
        trackerIDs = unique(vr_trackers_raw5(:,1));
        for itr2 = 1:1:length(trackerIDs)
            fld = strcat("tracker",string(trackerIDs(itr2)));
            rawVive.(fld) = vr_trackers_raw5(vr_trackers_raw5(:,1) ==  (trackerIDs(itr2)),:);
        end
    end
else
    disp("Tracker file is not available, check directory for file.")
end

%% ------- Removing 1sec of data from the top and 1 sec of data from the bottom ---------%%
fields = fieldnames(rawVive);
Vive = struct(); % raw cartesian coordinates

for itr4 = 1:1:length(fields)
    Vive.(fields{itr4})(:,1) = rawVive.(fields{itr4})(:,2);
    Vive.(fields{itr4})(:,2:13) = rawVive.(fields{itr4})(:,4:15);
    
    timer1 = 0;
    startIdx = 2;
    while timer1 < 2e+9 && startIdx > size(rawVive.(fields{itr4}),1) % 2 seconds
        timer1 = (Vive.(fields{ff})(startIdx,1) - Vive.(fields{ff})(1,1));
        startIdx = startIdx + 1;
    end
    
    timer2 =0;
    endIdx = size(rawVive.(fields{itr4}),1);
    while timer2 < 4e+9 && endIdx > 10 % 2 seconds
        timer2 = abs(Vive.(fields{itr4})(end,1) - Vive.(fields{itr4})(endIdx-1,1));
        endIdx = endIdx - 1;
    end
    
    Vive.(fields{itr4}) = Vive.(fields{itr4})(startIdx:endIdx,:);
end

%% Rounding up the timestamp to the 10th of the millisecond as the data collection...
%happens every 10 milliseconds and resampling rate is 100Hz
for itr5 = 1:1:length(fields)
    Vive.(fields{itr5})(:,1) = round(Vive.(fields{itr5})(:,1) * 1e-06,1); 
    % Nanoseconds to milliseconds and then rounding upto 1 decimal to have
    % 10th of the millisecond accuracy
end


%% TODO : Removing duplicate enteries

end
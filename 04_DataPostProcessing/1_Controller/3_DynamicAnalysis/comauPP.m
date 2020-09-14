function [Comau] = comauPP(filenameComau,delimiter)
%%This script for loading and visualising raw data extracted from
% comau motion feedback program through TCP/IP connection
% Velocity and Acceleration are calculated by time difference method
% author: @msihub , mohamedsadiq.ikbal@edu.unige.it

%%--------------------------------------------------------------------------%%
%RAW DATA FORMAT FROM COMAU:  [AbsTimestamp ComauClock positionX positionY positionZ rotatione1 rotatione2 rotatione3] % Roatation format ZYZ'
%UNITS:                       [nanoseconds seconds millimeters millimeters millimeters degrees degrees degrees]
%Delimiter: comma
%%--------------------------------------------------------------------------%%
%%-------------------------------------------------------------------------%%

%% Import text file
rawDataComau = importdata(filenameComau,delimiter);
Comau = zeros(size(rawDataComau,1),8);
% Comau_clock = rawDataComau(:,2); % seconds
Comau(:,1) = rawDataComau(:,1); %fprintf('Max t = %f \t Min t = %f \n', max(t), min(t)) % nanoseconds
%disp("POSITION")
Comau(:,2) = round(rawDataComau(:,3).*0.001,6);  %fprintf('Max posX = %f \t Min posX = %f \n', max(posX), min(posX)) % mm to meter rounded to micrometer accuracy
Comau(:,3)= round(rawDataComau(:,4).*0.001,6); % fprintf('Max posY = %f \t Min posY = %f \n', max(posY), min(posY)) % mm to meter
Comau(:,4) = round(rawDataComau(:,5).*0.001,6);  %fprintf('Max posZ = %f \t Min posZ = %f \n', max(posZ), min(posZ)) % mm to meter
Comau(:,5) = round(rawDataComau(:,6),6); %fprintf('Max rote1 = %f \t Min rote1 = %f \n', max(rote1), min(rote1))% deg
Comau(:,6) = round(rawDataComau(:,7),6); %fprintf('Max rote2 = %f \t Min rote2 = %f \n', max(rote2), min(rote2))% deg
Comau(:,7) = round(rawDataComau(:,8),6); %fprintf('Max rote3 = %f \t Min rote3 = %f \n\n', max(rote3), min(rote3))% deg
Comau(:,8) = round(rawDataComau(:,9),6); % Velocity TCP m/s

%% Removing abnormal values due to data corruption
datalimit = struct();% in meters and deg
datalimit.t = [ 0  1897853950000*1e+6]; % epoch time is always positive and max time is set to 20/2/2100;
datalimit.x = [-3 3];
datalimit.y = [-3 3];
datalimit.z = [-1 3];
datalimit.e1 = [-1000 1000]; % There is continous rotation in the 5th and 6th axis which produces the values more than 360
datalimit.e2 = [-1000 1000];
datalimit.e3 = [-1000 1000];

corrupt_idx = [];
corrupt_idx = [corrupt_idx; find(Comau(:,1)< datalimit.t(1) | Comau(:,1)> datalimit.t(2))];
corrupt_idx = [corrupt_idx; find(Comau(:,2)< datalimit.x(1) | Comau(:,2)> datalimit.x(2))];
corrupt_idx = [corrupt_idx; find(Comau(:,3)< datalimit.y(1) | Comau(:,3)> datalimit.y(2))];
corrupt_idx = [corrupt_idx; find(Comau(:,4)< datalimit.z(1) | Comau(:,4)> datalimit.z(2))];
corrupt_idx = [corrupt_idx; find(Comau(:,5)< datalimit.e1(1)| Comau(:,5)> datalimit.e1(2))];
corrupt_idx = [corrupt_idx; find(Comau(:,6)< datalimit.e2(1)| Comau(:,6)> datalimit.e2(2))];
corrupt_idx = [corrupt_idx; find(Comau(:,7)< datalimit.e3(1)| Comau(:,7)> datalimit.e3(2))];
corrupt_idx = unique(corrupt_idx); % Removing duplicate entries

Comau(corrupt_idx,:) = [];

%% Rounding up to 10th of the milliseconds as data is collected at every 10 milliseconds
Comau(:,1) = round(Comau(:,1) * 1e-6,1);
 % Nanoseconds to milliseconds and then rounding upto 1 decimal to have
    % 10th of the millisecond accuracy
    
%% Removing duplicate enteries
tdif = round(Comau(:,1) - Comau(1,1),1); %making relative timestamp and converting nanoseconds to seconds then rounding to millisecond accuracy
[~, ia, ~] = unique(tdif(:,1),'rows');

Comau = Comau(ia,:);



end
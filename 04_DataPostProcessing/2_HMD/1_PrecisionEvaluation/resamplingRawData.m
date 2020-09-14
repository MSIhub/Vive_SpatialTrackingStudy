function [resampledData, resampledTimestamp] = resamplingRawData(dataIn, desiredFs)
%resamplingRawData resampling raw data of comau and openvr over TCP/IP
%connection

% author: @msihub , mohamedsadiq.ikbal@edu.unige.it

%%--------INPUT------------------------------------------------------------%%
%dataIn:
% INPUT DATA FORMAT:  [AbsTimestamp positionX positionY positionZ rotatione1 rotatione2 rotatione3]
% UNITS:              [milliseconds meters meters meters degrees degrees degrees]
% DATA TYPE: MATRIX(n* 7)

%desiredFs:
% INTEGER: in Hertz, default: 100Hz

%%----------OUTPUT----------------------------------------------------------%%
%resampledData:n*6 Matrix [positionX positionY positionZ rotatione1 rotatione2 rotatione3]
%                          (m,m,m, deg, deg, deg)
%resampledTimestamp: n*1 Matrix seconds
%%--------------------------------------------------------------------------%%

if nargin < 2
    desiredFs = 100; % in Hz
end

StartTimestamp = dataIn(1,1)*1e-3; 
% -- making relative timestamp and converting milliseconds to seconds
dataIn(:,1) = (dataIn(:,1) - dataIn(1,1))*1e-3;

% calculating the nominal freq of the input data
freqDiff = zeros(length(dataIn(:,1)),1);
for i=2:1:length(dataIn(:,1))
    freqDiff(i,1) = dataIn(i,1) - dataIn(i-1,1);
end
nominalFs = 1/(mode(freqDiff));

% parameters of antialiasing filter
p = 1;
q = round((nominalFs/desiredFs));
% ensure an odd length filter
% n = 10*q+1;
n = 2*q+1;
% use .25 of Nyquist range of desired sample rate
cutoffRatio = .25;
% construct lowpass filter
lpFilt = p * fir1(n, cutoffRatio * 1/q);

[resampledData,resampledTimestamp] = resample(dataIn(:,2:end),dataIn(:,1),desiredFs,p,q,lpFilt);

% Ignoring top and both 5 values as they are prone to error as a result of
% antialiasing filtering
resampledData = resampledData(5:end-5,:);
resampledTimestamp = resampledTimestamp(5:end-5);
% Resetting the timestamp from 0
%resampledTimestamp(:,1) = resampledTimestamp(:,1)-resampledTimestamp(1,1);
resampledTimestamp(:,1)  = (StartTimestamp) + resampledTimestamp(:,1);
% figure()
% plot(dataIn(:,1),dataIn(:,2:end),'+-',resampledTimestamp,resampledData,'o:')
% legend('original','resampled','Location','best')
% % %xlim([0,0.1])


end
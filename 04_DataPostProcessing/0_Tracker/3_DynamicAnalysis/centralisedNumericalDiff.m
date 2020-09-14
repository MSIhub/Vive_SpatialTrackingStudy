function [Out] = centralisedNumericalDiff(inArray)
%centralisedNumericalDiff creates centralised numberical differentiation.
%%             x[k+1] - x[k-1]
% x_dot [k] = ---------------- = (x[k+1] - x[k-1])/2
%                       2
Out = [];
for k = 2 : length(inArray)-1
    theDiff = inArray(k+1) - inArray(k-1);
    Out(k-1) = (theDiff)/2;
end
Out = transpose(Out);
end

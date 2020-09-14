function [H, t, theta, T] = transformViveData(left,right)
FLOAT_PRECISION = 6;
%transformViveData Transforms left and right data with respect to a same coordinate
%frame into H: transformation between left and right
%   t = timestamp
%   theta: angle of rotation
%   T: translation vector extracted from H

% decompose data
%%%%%%%%%%%%%%%%%%%%
t_left = left(1,1);

T_left(1) = left(1,5);
T_left(2) = left(1,9);
T_left(3) = left(1,13);

R_left = [left(1,2), left(1,3), left(1,4);
    left(1,6), left(1,7), left(1,8);
    left(1,10), left(1,11), left(1,12);];

H_left = round([R_left, T_left'; [0, 0, 0, 1]],FLOAT_PRECISION);

%%%%%%%%%%%%%%%%%%%%%%%
t_right = right(1,1);

T_right(1) = right(1,5);
T_right(2) = right(1,9);
T_right(3) = right(1,13);

R_right = [right(1,2), right(1,3), right(1,4);
    right(1,6), right(1,7), right(1,8);
    right(1,10), right(1,11), right(1,12);];

H_right = round([R_right, T_right'; [0, 0, 0, 1]],FLOAT_PRECISION);

%check timestamp is same
if(t_right ~= t_left)
    error("Timestamp not matching for the data input, ensure synchronization");
end

% transform left to right
H = round(H_left\H_right,FLOAT_PRECISION);
R = round(H(1:3,1:3),FLOAT_PRECISION);
T = H(1:3,4);
t = t_left;
% angle of rotation
q = rotm2quat(R);
theta = 2 * asin(sqrt(q(2)^2 + q(3)^2 + q(4)^2));

end


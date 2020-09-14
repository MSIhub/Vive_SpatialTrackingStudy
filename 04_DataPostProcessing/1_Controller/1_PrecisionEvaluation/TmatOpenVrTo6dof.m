function [T, R, t, rot] = TmatOpenVrTo6dof(dataIn)
%TmatOpenVrTo6dof: Converting OpenVr Raw Transformation HmdMatrix34_t to six
%degree of freedom
%   Transformation matrix to cartesian coordinantes. 
%   t00 t01 t02 t03 t10 t11 t12 t13 t20 t21 t22 t23
%   Positions in meters, rotations in euler angles ZYZ convention in deg

posX = dataIn(4);
posY = dataIn(8);
posZ = dataIn(12);

R = [dataIn(1), dataIn(2), dataIn(3);
    dataIn(5), dataIn(6), dataIn(7);
    dataIn(9), dataIn(10), dataIn(11);];
eulZYZ =  tr2eul(R,'deg'); % Tool from peter corke toolbox as the COMAU kinematics are based on it

rote1 = wrapTo180(eulZYZ(1));
rote2 = wrapTo180(eulZYZ(2));
rote3 = wrapTo180(eulZYZ(3));


t = [posX, posY, posZ]';
rot = [rote1, rote2, rote3]';

T = [R, t; [0 0 0 1]];
end


function [T_v,T_c] = TmatVC(dataV,dataC)
%TmatVC Transforms the Vive raw data to the Transformation matrix 4*4
%homogenous matrix and comau raw data to the same.

R_v = [dataV(2), dataV(3), dataV(4);...
    dataV(6), dataV(7), dataV(8);...
    dataV(10), dataV(11), dataV(12)];
t_v = [dataV(5), dataV(9), dataV(13)]';
T_v =[R_v, t_v; [0 0 0 1]];

R_c = eul2r(dataC(5), dataC(6), dataC(7),'deg'); % ZYZ peter corke
t_c = [dataC(2), dataC(3), dataC(4)]';
T_c = [R_c, t_c; [0 0 0 1]];

end


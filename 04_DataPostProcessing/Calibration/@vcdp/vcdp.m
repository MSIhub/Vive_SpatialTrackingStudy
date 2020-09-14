classdef vcdp
%%vcdp This class is a library for post processing of vive & comau data collected via TCP/IP developed tool in C++.
%   Author: Mohamed Sadiq Ikbal
    %   Contact: mohamedsadiq.ikbal@edu.unige.it
    %   Github repo:
    
    % Prerequisites:
    % RTB-10.4: Robotics toolbox 10.4 (PeterCorke toolbox)
    methods (Static, Sealed)
        
        %%calibViveComau ----------------------------------%
        function [T,AngleOffset, O] = ...
                calibrateViveComau(M,N,choice_of_algorithm,filenameComau)
            %%calibrateViveComau Run calibration algorithm. Choice available: cashbugh(default), arun and umyema.
            %Out: T, AngleOffset, O
                % T -> Calibrated Transformation matrix
                % AngleOffset -> Ideal angle offset
                % O -> 3*N output for the M to N matrix for the calibration data
            %In: M,N,choice_of_algorithm
                %M -> Data frame that has to be transformed (from)(3*N)
                %N -> Reference Data frame (to)(3*N)
                %choice_of_algorithm  -> 1 = Cashbaugh, 2 = Arun, 3 = Umeyama
            
            strapp = " ";
            if nargin < 3
                choice_of_algorithm = 1;
            end
            
            switch choice_of_algorithm
                case 1
                    %%----Cashbaugh 2018----%%
                    [T, ~, ~] = vcdp.rbtCashbaugh(M(:,2:4).',N(:,2:4).');
                    strapp = "Cashbaugh";
                case 2
                    %%----Arunetal, SVD rot cal and least square 1987----%%
                    [ret_R, ret_t] = vcdp.rbtArunetal(M(:,2:4).',N(:,2:4).');
                    T(1:3,1:3) = ret_R; T(1:3,4) = ret_t;
                    T(4,:) = [0 0 0 1];
                    strapp = "Arun";
                case 3
                    %%----Umeyama 1991----%%
                    [ret_R, ret_t] = vcdp.rbtUmeyama(M(:,2:4).',...
                        N(:,2:4).',true);
                    T(1:3,1:3) = ret_R; T(1:3,4) = ret_t;
                    T(4,:) = [0 0 0 1];
                    strapp = "Umeyama";
            end
            
            num_of_data = size(M,1);
            
            %%Transforming the data collected in data frame M to
            %data frame N and storing in O
            O = zeros(num_of_data, 7);
            O(:,1) = M(:,1);
            
            for itr6 = 1:1:num_of_data
                % Form transformation matrix from 6dof for each value
                T1(1:3,1:3) = eul2r(wrapToPi(deg2rad(M(itr6,5:7))));
                T1 = round(T1,4);
                T1(1:3,4) = [M(itr6,2), M(itr6,3), M(itr6,4)];
                T1(4,:) = [0, 0, 0, 1];
                
                % Multiply with T found transformation matrix
                T2 = T*T1;
                % Find 6dof from T and Store it in an array
                [posX, posY, posZ, rote1, rote2, rote3] = ...
                    vcdp.Tmat2Cartesian(T2);
                O(itr6,2:7) = [posX, posY, posZ, rote1, rote2 , rote3];
            end
            
            %%Optimization for angle offset
            % min_beta(sum(theta_i - alpha_i + beta)^2)
            theta_a = O(:,5);
            alpha_a = N(:,5);
            fun = @(beta_a)vcdp.minAngleOffset(beta_a,theta_a, alpha_a);
            lim = [-pi, pi];
            beta_a = fminsearch(fun,lim);
            
            
            theta_e = O(:,6);
            alpha_e = N(:,6);
            fun = @(beta_e)vcdp.minAngleOffset(beta_e,theta_e, alpha_e);
            lim = [-pi, pi];
            beta_e = fminsearch(fun,lim);
            
            theta_r = O(:,7);
            alpha_r = N(:,7);
            fun = @(beta_r)vcdp.minAngleOffset(beta_r,theta_r, alpha_r);
            lim = [-pi, pi];
            beta_r = fminsearch(fun,lim);
            
            AngleOffset= [beta_a(1), beta_e(1), beta_r(1)];
            % Adding offset to the transformed data
            
            O(:,5:7) = O(:,5:7) + AngleOffset;
            
            
            %%Saving the output varibles to the mat file
            %%----Refactoring the variable to be secure to changes when saving----%%
            viveData = M;
            comauData = N;
            transformedViveData = O;
            
            if ~exist('calibrationFiles', 'dir')
                mkdir('calibrationFiles')
            end
            %%----Extracting the timestamp from the filename to match filename and mat file----%%
            ffff = regexp(filenameComau,'[0-9]','match');
            folderName = "calibrationFiles/";
            newStr = join(ffff,"");
            newStr = newStr.append(strapp,".mat");
            save(folderName.append(newStr),'comauData','viveData','transformedViveData', 'T', 'AngleOffset' );
            fprintf("Result data are saved in '%s' \n", folderName.append(newStr))
        end
        
        function [T, R33, t13] = rbtCashbaugh(pA,pB)
            %%rbtCashbaugh: An adaptation of math from the paper "J. Cashbaugh, C. Kittis: Automatic Calculation of a transformation Matrix between two frames"
            % DOI:10.1109/ACCESS.2018.2799173
            
            % VERIFIED WITH THE EXAMPLE IN THE PAPER MENTIONED ABOVE
            
            % Two points from two frames wrt themselves with one to one
            % correspondance
            % 3 * n format [x y z 1] ; n -> number of sample points
            % pB  = T  * pA
            
            if size(pA,2) ~= size(pB,2)
                error("Size of two input matrices are not same,")
                error("ensure one to one correspondance")
            else
                n = size(pA,2);
                fprintf("Number of samples taken  = %d\n",n);
            end
            
            
            xA = pA(1,:);
            yA = pA(2,:);
            zA = pA(3,:);
            
            xB = pB(1,:);
            yB = pB(2,:);
            zB = pB(3,:);
            
            % calculating A matrix
            
            A = zeros(4,4);
            
            A(1,1) = sumsqr(xA);
            A(1,2) = sum(xA.*yA);
            A(1,3) = sum(xA.*zA);
            A(1,4) = sum(xA);
            
            A(2,1) = sum(xA.*yA);
            A(2,2) = sumsqr(yA);
            A(2,3) = sum(yA.*zA);
            A(2,4) = sum(yA);
            
            A(3,1) = sum(xA.*zA);
            A(3,2) = sum(yA.*zA);
            A(3,3) = sumsqr(zA);
            A(3,4) = sum(zA);
            
            A(4,1) = sum(xA);
            A(4,2) = sum(yA);
            A(4,3) = sum(zA);
            A(4,4) = n;
            
            %
            
            L1 = [sum(xB.*xA); sum(xB.*yA); sum(xB.*zA); sum(xB)];
            L2 = [sum(yB.*xA); sum(yB.*yA); sum(yB.*zA); sum(yB)];
            L3 = [sum(zB.*xA); sum(zB.*yA); sum(zB.*zA); sum(zB)];
            
            % Taking into account Border cases
            % A is not invertible if and only if det(A) equal to Zero.
            
            if det(A)~=0
                iA = inv(A);
            else
                iA = pinv(A);
                disp("Matrix A was not invertible->pseudo inverse was calculated")
            end
            
            % cal Transformation matrix
            T = zeros(4,4);
            T(1,:) = (iA*L1)';
            T(2,:) = (iA*L2)';
            T(3,:) = (iA*L3)';
            T(4,:) = [0 0 0 1];
            
            R33 = T(1:3,1:3);
            t13 = T(1:3,4);
            
        end
        
        function [R,t] = rbtArunetal(A, B)
            %%This function finds the optimal Rigid/Euclidean transform in 3D space
            %It expects as input a 3xN matrix of 3D points.
            %It returns R, t
            
            % expects row data
            if nargin ~= 2
                error("Missing parameters");
            end
            
            assert(size(A,1) == size(B,1) && size(A,2) == size(B,2));
            
            [num_rows, num_cols] = size(A);
            if num_rows ~= 3
                error("matrix A is not 3xN, it is %dx%d", num_rows, num_cols)
            end
            
            [num_rows, num_cols] = size(B);
            if num_rows ~= 3
                error("matrix B is not 3xN, it is %dx%d", num_rows, num_cols)
            end
            
            % find mean column wise
            centroid_A = mean(A, 2);
            centroid_B = mean(B, 2);
            
            % subtract mean
            Am = A - repmat(centroid_A, 1, num_cols);
            Bm = B - repmat(centroid_B, 1, num_cols);
            
            % calculate covariance matrix (is this the corrcet term?)
            H = Am * Bm';
            
            % find rotation
            [U,S,V] = svd(H);
            R = V*U';
            
            if det(R) < 0
                sprintf("det(R)<R,reflection detected!, correcting for it ...\n");
                V(:,3) = V(:,3) * (-1);
                R = V*U';
            end
            
            t = -R*centroid_A + centroid_B;
        end
        
        function [ R, t ] = rbtUmeyama( X, Y, plotResult )
            %rbtUmeyama Corresponding point set registration with Umeyama method.
            %
            % [R, t] = umeyama(X, Y) 
            %   returns the rotation matrix R and translation
            % vector t that approximate Y = R * X + t using
            %   least-squares estimation. 
            % X and Y are in format [3xn] and point X(:,i) 
            %   corresponds to point Y(:,i) for all i.
            %
            % [R, t] = umeyama(X, Y, true)  
            %   returns the same result but in addition a
            % figure is created plotting the registration result
            %   and the average registration error.
            %
            % Author: Christoph Graumann, 2015

            assert(size(X,1)==size(Y,1) && size(X,2)==size(Y,2),...
                'Dimensions of matrices must match!');
            assert(size(X,1)==3, 'The points must be given in format [3xn]');
            
            %%Demean
            m = size(X,1);
            n = size(X,2);
            mean_X = mean(X,2);
            mean_Y = mean(Y,2);
            X_demean = X - repmat(mean_X,1,size(X,2));
            Y_demean = Y - repmat(mean_Y,1,size(Y,2));
            
            %%SVD
            sigma = 1/n*Y_demean*X_demean';
            [U,~,V] = svd(sigma);
            
            %%Define S
            S = eye(m);
            if det(sigma) < 0 || (rank(sigma) == m-1 && det(U)*det(V) < 0)
                S(m,m) = -1;
            end
            
            %%Bootstrap
            R = U*S*V';
            t = mean_Y - R*mean_X;
            
            %%Plotting
            if nargin>2 && plotResult
                figure('name','Result of Umeyama registration');
                scatter3(X(1,:),X(2,:),X(3,:),'g*');
                hold on;
                scatter3(Y(1,:),Y(2,:),Y(3,:),'bo');
                X_prime = [R t; 0 0 0 1] * [X;ones(1,size(X,2))];
                scatter3(X_prime(1,:),X_prime(2,:),X_prime(3,:),'r*');
                axis equal tight;
                legend('Source points','Destination points',...
                    'Transformation result');
                MEAN_REGISTRATION_ERROR = norm(mean(abs(Y...
                    - X_prime(1:3,:)),2))
            end
            
        end
        
        function f = minAngleOffset(beta, theta, alpha)
            f = 0;
            for i = 1:1:length(theta)
                f = f + sum((theta(i) - alpha(i) + beta).^2);
            end
        end
        %%---------------------------------------------------------------%%
    
        
        %%vivePP ------------------------------------------------------- %%
        function [rawCarVive] = vivePP(filenameHmd,filenameController,...
                filenameTracker,delimiter)
            %vivePP This script for loading and visualising raw extracted from OpenVR scripts and clientComau application through TCP/IP connection
            % author: @msihub , mohamedsadiq.ikbal@edu.unige.it
            disp("Running vivePP, vive post processing function");
            %%-----------------------------------------------------------%%
            %RAW DATA FORMAT FROM openVR:
            %[ID AbsTimestamp ViveClock t00 t01 t02 t03 t10 t11 t12 t13 t20
            %t21 t22 t23] %
            %UNITS:
            %[integer nanoseconds nanoseconds relativeFloatUnits ]
            %Delimiter: comma
            %T = [t00 t01 t02 t03
            %     t10 t11 t12 t13
            %     t20 t21 t22 t23]
            %%-----------------------------------------------------------%%
            if nargin < 4
                error("Number of arguments must be four;")
                error("even if some files are not present");
            end
            flnh = filenameHmd;
            flnc = filenameController;
            flnt = filenameTracker;
            %%-----------------------------------------------------------%%
            %If the file is empty delete the file
            %%-----------------------------------------------------------%%
            %%Import text file to the struct in the following order
            %------------ STRUCT
            % rawDataVive:
            %      hmd
            %      controller1
            %      controller2
            %      tracker1
            %      ...
            %      trackern
            %------------------------
            rawDataVive = struct();
            % HMD
            if isfile(flnh)
                rawDataVive.hmd = importdata(flnh,delimiter);
            else
                disp("HMD file is not available, check directory for file.")
            end
            % Controller (seperate Right and left)
            if isfile(flnc)
                vr_controllers_raw = importdata(flnc,delimiter);
                if (isempty(vr_controllers_raw))
                    disp("VR controllers file is empty,")
                else
                    rawDataVive.controller1 =...
                        vr_controllers_raw(vr_controllers_raw(:,1) == 1,:);
                    rawDataVive.controller2 =...
                        vr_controllers_raw(vr_controllers_raw(:,1) == 2,:);
                    
                    if (isempty(rawDataVive.controller1))
                        rawDataVive = rmfield(rawDataVive, 'controller1');
                        % removing the field if empty
                        disp("VR controllers with ID 1 is empty")
                    end
                    if (isempty(rawDataVive.controller2))
                        rawDataVive = rmfield(rawDataVive, controller2);
                        % removing the field if empty
                        disp("VR controllers with ID 2 is empty")
                    end
                    
                end
            else
                disp("Controller file is not available, check directory for file.")
            end
            %Tracker (handling multiple trackers)
            if isfile(flnt)
                vr_trackers_raw = importdata(flnt,delimiter);
                % Extract and organise data from the file
                if (isempty(vr_trackers_raw))
                    disp("VR trackers file is empty,")
                    disp("check whether the devices were connected.")
                    disp("If no controllers are connected,")
                    disp("the data will be in controller file")
                else
                    trackerIDs = unique(vr_trackers_raw(:,1));
                    for kk = 1:1:length(trackerIDs)
                        fld = strcat("tracker",string(trackerIDs(kk)));
                        rawDataVive.(fld) = vr_trackers_raw(vr_trackers_raw(:,1)...
                            ==  (trackerIDs(kk)),:);
                    end
                end
            else
                disp("Tracker file is not available, check directory for file.")
            end
            %%TODO : Removing duplicate enteries
            %%------- Transformation Matrix to 6dof data ------------- %%
            fields = fieldnames(rawDataVive);
            rawCarVive = struct(); % raw cartesian coordinates
            
            for ff = 1:1:length(fields)
                rawCarVive.(fields{ff})(:,1) = rawDataVive.(fields{ff})(:,2);
                for ii = 1:1:size(rawDataVive.(fields{ff}),1)
                    [rawCarVive.(fields{ff})(ii,2),...
                        rawCarVive.(fields{ff})(ii,3),...
                        rawCarVive.(fields{ff})(ii,4),...
                        rawCarVive.(fields{ff})(ii,5),...
                        rawCarVive.(fields{ff})(ii,6),...
                        rawCarVive.(fields{ff})(ii,7)] =...
                        vcdp.TmatOpenVrTo6dof(rawDataVive.(fields{ff})(ii,4:end));
                end
            end
            %%------- Removing 2 sec of data from the top and
            %------- 4 sec of data from the bottom ---------%%
            for ff1 = 1:1:length(fields)
                rawCarVive.(fields{ff1})(:,1) = rawDataVive.(fields{ff1})(:,2);
                for ii = 1:1:size(rawDataVive.(fields{ff1}),1)
                    timer1 = 0;
                    startIdx = 2;
                    while timer1 < 2e+9 && startIdx > ...
                            size(rawDataVive.(fields{ff1}),1) % 2 seconds
                        timer1 = (rawCarVive.(fields{ff})(startIdx,1)...
                            - rawCarVive.(fields{ff})(1,1));
                        startIdx = startIdx + 1;
                    end
                    
                    timer2 =0;
                    endIdx = size(rawDataVive.(fields{ff1}),1);
                    while timer2 < 4e+9 && endIdx > 10 % 4 seconds
                        timer2 = abs(rawCarVive.(fields{ff})(end,1)...
                            - rawCarVive.(fields{ff})(endIdx-1,1));
                        endIdx = endIdx - 1;
                    end
                end
                rawCarVive.(fields{ff1}) = ...
                    rawCarVive.(fields{ff1})(startIdx:endIdx,:);
            end
        end
        
        function [posX, posY, posZ, rote1, rote2, rote3] = ...
                TmatOpenVrTo6dof(dataIn)
            %TmatOpenVrTo6dof Converting OpenVr Raw Transformation HmdMatrix34_t to six degree of freedom
            %   Transformation matrix to cartesian coordinantes.
            %   t00 t01 t02 t03 t10 t11 t12 t13 t20 t21 t22 t23
            %   Positions in meters, rotations in euler angles ZYZ convention in deg
            
            posX = dataIn(4);
            posY = dataIn(8);
            posZ = dataIn(12);
            
            R = [dataIn(1), dataIn(2), dataIn(3);
                dataIn(5), dataIn(6), dataIn(7);
                dataIn(9), dataIn(10), dataIn(11);];
            eulZYZ =  tr2eul(R,'deg');
            %Tool from Peter corke toolbox as the COMAU kinematics uses it
            rote1 = wrapTo180(eulZYZ(1));
            rote2 = wrapTo180(eulZYZ(2));
            rote3 = wrapTo180(eulZYZ(3));
        end
        %%---------------------------------------------------------------%%

        
        %%comauPP------------------------------------------------------- %%
        function [nonDuplicateDataComau] = comauPP(filenameComau,...
                delimiter)
            %comauPP This script for loading and visualising raw data extracted from comau motion feedback program through TCP/IP connection
            % Velocity and Acceleration are calculated by time difference method
            % author: @msihub , mohamedsadiq.ikbal@edu.unige.it
            
            %%-----------------------------------------------------------%%
            %RAW DATA FORMAT FROM COMAU:
            %[AbsTimestamp ComauClock positionX positionY positionZ...
            %rotatione1 rotatione2 rotatione3]
            % Roatation format ZYZ'
            %UNITS:
            %[nanoseconds seconds millimeters millimeters millimeters...
            %degrees degrees degrees]
            %Delimiter: comma
            %%-----------------------------------------------------------%%
            %%Import text file
            rawDataComau = importdata(filenameComau,delimiter);
            % Comau_clock = rawDataComau(:,2); % seconds
            t = rawDataComau(:,1);
            %fprintf('Max t = %f \t Min t = %f\n', max(t), min(t))
            %nanoseconds
            %disp("POSITION")
            posX = round(rawDataComau(:,3).*0.001,6);
            %fprintf('Max posX = %f\tMin posX = %f\n',max(posX),min(posX))
            % mm to meter rounded to micrometer accuracy
            posY = round(rawDataComau(:,4).*0.001,6);
            % fprintf('Max posY = %f\tMin posY = %f\n',max(posY),min(posY))
            % mm to meter
            posZ = round(rawDataComau(:,5).*0.001,6);
            %fprintf('Max posZ = %f\tMin posZ = %f\n',max(posZ),min(posZ))
            % mm to meter
            rote1 = round(rawDataComau(:,6),6);
            %fprintf('Max rote1 = %f\tMin rote1 = %f\n',max(rote1),min(rote1))
            % deg
            rote2 = round(rawDataComau(:,7),6);
            %fprintf('Max rote2 = %f\tMin rote2 = %f\n',max(rote2),min(rote2))
            % deg
            rote3 = round(rawDataComau(:,8),6);
            %fprintf('Max rote3 = %f\tMin rote3 = %f\n\n',max(rote3),min(rote3))
            % deg
            
            %%Removing abnormal values due to data corruption
            datalimit = struct();% in meters and deg
            datalimit.t = [ 0  1897853950000*1e+6];
            % epoch time is always positive and max time is set to 20/2/2100;
            datalimit.x = [-3 3];
            datalimit.y = [-3 3];
            datalimit.z = [0 2.5];
            datalimit.e1 = [-180 180];
            datalimit.e2 = [-180 180];
            datalimit.e3 = [-180 180];
            
            idx = struct();
            idx.t =find(t(:)>=datalimit.t(1) & t(:)<=datalimit.t(2));
            idx.x=find(posX(:)>=datalimit.x(1) & posX(:)<=datalimit.x(2));
            idx.y=find(posY(:)>=datalimit.y(1) & posY(:)<=datalimit.y(2));
            idx.z=find(posZ(:)>=datalimit.z(1) & posZ(:)<=datalimit.z(2));
            idx.e1=find(rote1(:)>=datalimit.e1(1)&rote1(:)<=datalimit.e1(2));
            idx.e2=find(rote2(:)>=datalimit.e2(1)&rote1(:)<=datalimit.e2(2));
            idx.e3=find(rote3(:)>=datalimit.e3(1)&rote1(:)<=datalimit.e3(2));
            
            act_idx = (1:1:size(rawDataComau,1)).';
            fld = fieldnames(idx);
            for i =1:1:length(fld)-1
                for j = 1:1:length(fld)-1
                    nonDuplicateIndex = setdiff(idx.(fld{i}),idx.(fld{j}));
                    act_idx(nonDuplicateIndex) = -1;
                end
            end
            
            corruptDataIdx = find(act_idx == -1);
            t(corruptDataIdx) = [];
            posX(corruptDataIdx) = [];
            posY(corruptDataIdx) = [];
            posZ(corruptDataIdx) = [];
            rote1(corruptDataIdx) = [];
            rote2(corruptDataIdx) = [];
            rote3(corruptDataIdx) = [];
            
            %%Removing duplicate enteries
            tdif_unique = round((t - t(1))*1e-9,3);
            %making relative timestamp and converting...
            %nanoseconds to seconds then rounding to millisecond accuracy
            [~, ia, ~] = unique(tdif_unique(:,1),'rows');
            
            nonDuplicateDataComau = [];
            nonDuplicateDataComau(:,1) = t(ia);
            nonDuplicateDataComau(:,2) = posX(ia);
            nonDuplicateDataComau(:,3) = posY(ia);
            nonDuplicateDataComau(:,4) = posZ(ia);
            nonDuplicateDataComau(:,5) = rote1(ia);
            nonDuplicateDataComau(:,6) = rote2(ia);
            nonDuplicateDataComau(:,7) = rote3(ia);
        end
        %%---------------------------------------------------------------%%
        
        %%postProcessViveComau ----------------------------------------- %%
        function [transformedViveData, comauData, viveData] ...
                = postProcessViveComau(fc,fh,fcont,ft,calibfile,...
                resamplingRate, ffff)
            %postProcessViveComau This script is for post processing the collected vive and comau data. This is an encapsulation of
            %%various functions in this class
            isCalibrationOn = false;
            delimiterV = ",";
            delimiterC = ",";
            VisualiseRawDataComau = false;
            filenameComau = fc;
            filenameHmd = fh;
            filenameController = fcont;
            filenameTracker = ft;
            %###################################################################%%
            %%Loading and post proccesing data for comau and vive
            nonDuplicateDataComau = vcdp.comauPP(filenameComau,delimiterC,...
                VisualiseRawDataComau);
            rawCarVive = vcdp.vivePP(filenameHmd,filenameController,...
                filenameTracker,delimiterV);
            
            %###################################################################%%
            %%Synchronising vive and comau
            %out: point correspondance data M: struct, N:comau array
            %%BE CAREFUL OF THE RMOUTLIERS PECENTILE, IT MUST BE TUNED PER DATASET
            [M,N] = vcdp.syncViveComau(nonDuplicateDataComau,rawCarVive,...
                resamplingRate, isCalibrationOn);
            
            %%Transforming from collected vive data from vive frame to comau frame
            num_of_data = size(M,1);
            fields = fieldnames(rawCarVive);
            load(calibfile); disp('calib file loaded');
            if (exist('T','var') && exist('AngleOffset','var'))
                for j = 1:1:length(fields)
                    [O] = vcdp.transformViveComau(M.(fields{j}), T, AngleOffset);
                    transformData.(fields{j}).O = O;
                    transformData.(fields{j}).T = T;
                    transformData.(fields{j}).AngleOffset = AngleOffset;
                end
            else
                error('Calibration data missing, ensure that calibration is run');
            end
            
            %%Saving the three output varibles to the mat file
            %%----Refactoring the variable to be secure to changes when saving----%%
            viveData = M.(fields{1});
            comauData = N;
            transformedViveData = transformData.(fields{1}).O;
            T = transformData.(fields{1}).T;
            AngleOffset = transformData.(fields{1}).AngleOffset;
            
            if ~exist('results', 'dir')
                mkdir('results')
            end
            
            folderName = "results/";
            newStr = join(ffff,"");
            newStr = newStr.append(".mat");
            save(folderName.append(newStr),'comauData','viveData',...
                'transformedViveData', 'T', 'AngleOffset' );
            fprintf("Result data are saved in '%s' \n", folderName.append(newStr))
        end
        
        function [resampledData, resampledTimestamp] =...
                resamplingRawData(dataIn, desiredFs)
            %resamplingRawData resampling raw data of comau
            %and openvr over TCP/IP connection
            
            % author: @msihub , mohamedsadiq.ikbal@edu.unige.it
            
            %%--------INPUT----------------------------------------------%%
            %dataIn:
            % INPUT DATA FORMAT:
            %[AbsTimestamp positionX positionY positionZ rotatione1
            %rotatione2 rotatione3]
            % UNITS:
            %[nanoseconds meters meters meters degrees degrees degrees]
            % DATA TYPE: MATRIX(n* 7)
            
            %desiredFs:
            % INTEGER: in Hertz, default: 100Hz
            
            %%----------OUTPUT-------------------------------------------%%
            %resampledData:n*6 Matrix
            %[positionX positionY positionZ rotatione1 rotatione2 rotatione3]
            %(m,m,m, deg, deg, deg)
            %resampledTimestamp: n*1 Matrix seconds
            %%-----------------------------------------------------------%%
            
            if nargin < 2
                desiredFs = 100; % in Hz
            end
            
            StartTimestamp = dataIn(1,1)*1e-9;
            % Using PC timestamp in nanoseconds
            % making relative timestamp and converting nanoseconds to seconds
            dataIn(:,1) = (dataIn(:,1) - dataIn(1,1))*1e-9;
            
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
            
            [resampledData,resampledTimestamp] = resample(dataIn(:,2:end)...
                ,dataIn(:,1),desiredFs,p,q,lpFilt);
            
            % Ignoring top and both 5 values as they are prone to
            % error as a result of antialiasing filtering
            resampledData = resampledData(5:end-5,:);
            resampledTimestamp = resampledTimestamp(5:end-5);
            % Resetting the timestamp from 0
            %resampledTimestamp(:,1) =
            %resampledTimestamp(:,1)-resampledTimestamp(1,1);
            resampledTimestamp(:,1)  = (StartTimestamp) + resampledTimestamp(:,1);
            % figure()
            % plot(dataIn(:,1),dataIn(:,2:end),'+-',
            %resampledTimestamp,resampledData,'o:')
            % legend('original','resampled','Location','best')
            % % %xlim([0,0.1])
            
        end
        
        function [M,N] = syncViveComau(nonDuplicateDataComau,rawCarVive,...
                resamplingRate, isCalibrationOn)
            %syncViveComau Syncronising the collected exp data from vive and comau
            % checking the duration of data collected: ideally time duration for
            %vive is little higher than comau but if it is a lot(> 45 seconds)
            %then vive did not collected data
            % Synchronizing data
            %   Finding the index of the starting timestamp matching
            %   Matching the start time
            %   Resampling synchronised data
            %   Removing the extra data
            % Distance Calculation of the trajectory to verify synchronization
            %
            if nargin<3
                isCalibrationOn = false;
                resamplingRate = 100;
            end
            %%checking the duration of data collected
            timeDurationComau = (nonDuplicateDataComau(end,1)...
                - nonDuplicateDataComau(1,1))* 1e-06; % nano to milli
            disp('time duration for Comau');
            disp(timeDurationComau);
            
            fields = fieldnames(rawCarVive);
            timeDurationVive = struct();
            for itr1= 1:1:length(fields)
                timeDurationVive.(fields{itr1}) =...
                    (rawCarVive.(fields{itr1})(end,1)...
                    - rawCarVive.(fields{itr1})(1,1))* 1e-06; % nano to milli
                disp('time duration for Vive');
                disp(timeDurationVive.(fields{itr1}));
                if (abs((timeDurationVive.(fields{itr1}))...
                        - timeDurationComau)) > 4.5*1e4
                    error('Time differnce > 45 seconds, check raw data');
                end
            end
            
            %%Synchronizing data
            fields = fieldnames(rawCarVive);
            %%----Finding the index of the starting timestamp matching----%%
            A = round(nonDuplicateDataComau(:,1)*1e-6); % Nano to milli
            B = round(rawCarVive.(fields{1})(:,1)*1e-6); % Nano to milli
            
            if size(A,1)>size(B,1)
                B(size(B,1):size(A,1),:)= -11111111;
            elseif size(A,1)<size(B,1)
                A(size(A,1):size(B,1),:) = -11111111;
            else
                return;
            end
            
            [~,C1] = ismember(B,A);
            
            [ind] = find(C1~=0);
            matind = C1(ind);
            
            %%----Matching the start time----%%
            syncedComauData = nonDuplicateDataComau(matind(1):end,:);
            syncedViveData = struct();
            for itr1= 1:1:length(fields)
                syncedViveData.(fields{itr1}) =...
                    rawCarVive.(fields{itr1})(ind(1):end,:);
            end
            
            %%Resampling synchronised data----%%
            %%----vive----%%
            resampledDataVive = struct();
            for itr2= 1:1:length(fields)
                [rdv,rtv] = vcdp.resamplingRawData...
                    (syncedViveData.(fields{itr2}),resamplingRate);
                resampledDataVive.(fields{itr2})(:,1) = rtv;
                resampledDataVive.(fields{itr2})(:,2:7) = rdv;
            end
            
            %%----Comau----%%
            [rdc, rtc] = vcdp.resamplingRawData(syncedComauData...
                , resamplingRate);
            resampledDataComau(:,1) = rtc;
            resampledDataComau(:,2:7) = rdc;
            
            %-------------------------------------------------------------%
            %%----Removing the extra data----%%
            if size(resampledDataComau,1) <= size(resampledDataVive.(fields{1}),1)
                endLen = size(resampledDataComau,1);
            else
                endLen = size(resampledDataVive.(fields{1}),1);
            end
            Comau = resampledDataComau(1:endLen,:);
            Vive = struct();
            for itr3 = 1:1:length(fields)
                Vive.(fields{itr3})=resampledDataVive.(fields{itr3})(1:endLen,:);
            end
            %-------------------------------------------------------------%
            %%---- Removing the outlier and it corresponding value to
            %avoid overfitting
            %%TODO: Maybe use some filters to smooth the data
            %: filter smoothens the
            %%data, we want to calibrate raw data
            % Check must be done on both sides of data
            vive_rmoutliers = struct();
            if isCalibrationOn
                for itr4 = 1:1:length(fields)
                    [vive_rmoutliers.(fields{itr4})(:,2:7),TF_v] = ...
                        rmoutliers(Vive.(fields{itr4})(:,2:7),...
                        'percentiles',[15 90]);
                    vive_rmoutliers.(fields{itr4})(:,1) =...
                        Vive.(fields{itr4})(~TF_v,1);
                    
                    Comau_rm = Comau(~TF_v,:);
                    [comau_rmoutliers(:,2:7), TF_c ]= ...
                        rmoutliers(Comau_rm(:,2:7));
                    comau_rmoutliers(:,1) = Comau_rm(~TF_c,1);
                    vive_rmoutliers.(fields{itr4}) = ...
                        vive_rmoutliers.(fields{itr4})(~TF_c,:);
                    
                    Comau = comau_rmoutliers;
                    Vive.(fields{itr4}) = vive_rmoutliers.(fields{itr4});
                end
            end
            %-------------------------------------------------------------%
            
            %%----Making the timestamp relative----%%
            for itr5 = 1:1:length(fields)
                Vive.(fields{itr5})(:,1)=Vive.(fields{itr5})(:,1)...
                    - Vive.(fields{itr5})(1,1);
            end
            Comau(:,1) = Comau(:,1) - Comau(1,1);
            %-------------------------------------------------------------%
            
            %%Distance Calculation of the trajectory to verify synchronization
            dxc = max(Comau(:,2)) - min(Comau(:,2));
            dyc = max(Comau(:,3)) - min(Comau(:,3));
            dzc = max(Comau(:,4)) - min(Comau(:,4));
            distComau = sqrt(dxc^2 + dyc^2 + dzc^2);
            
            distVive = struct();
            for itr6 = 1:1:length(fields)
                dxv = max(Vive.(fields{itr6})(:,2)) - min(Vive.(fields{itr6})(:,2));
                dyv = max(Vive.(fields{itr6})(:,3)) - min(Vive.(fields{itr6})(:,3));
                dzv = max(Vive.(fields{itr6})(:,4)) - min(Vive.(fields{itr6})(:,4));
                distVive.(fields{itr6}) = sqrt(dxv^2 + dyv^2 + dzv^2);
            end
            
            distErrorMM = (distVive.(fields{1}) - distComau) *1000;
            disp('Euclidean distance between Vive and Comau in mm');
            disp(distErrorMM);
            %%----Calibration points----%%
            M = struct();
            for itr7 = 1:1:length(fields)
                M.(fields{1}) = Vive.(fields{1}); % Data frame that has to be
                %transformed (from)
            end
            N = Comau; % Reference Data frame (to)
        end
        
        function [posX, posY, posZ, rote1, rote2, rote3] =...
                Tmat2Cartesian(T)
            %Tmat2Cartesian Standard Transformation matrix to cartesian coordinates
            %   4*4 T matrix to 6 dof data
            R = round(T(1:3,1:3),4);
            eulZYZ =  tr2eul(R,'deg');
            posX = T(1,4);
            posY = T(2,4);
            posZ = T(3,4);
            rote1 = wrapTo180(eulZYZ(1));
            rote2 = wrapTo180(eulZYZ(2));
            rote3 = wrapTo180(eulZYZ(3));
        end
        
        function [O] = transformViveComau(M, T, AngleOffset)
            %transformViveComau Summary of this function goes here
            %   Detailed explanation goes here
            num_of_data = size(M,1);
            O = zeros(num_of_data, 7);
            O(:,1) = M(:,1);
            
            for itr6 = 1:1:num_of_data
                % Form transformation matrix from 6dof for each value
                T1(1:3,1:3) = eul2r(wrapToPi(deg2rad(M(itr6,5:7))));
                T1 = round(T1,4);
                T1(1:3,4) = [M(itr6,2), M(itr6,3), M(itr6,4)];
                T1(4,:) = [0, 0, 0, 1];
                
                % Multiply with T found transformation matrix
                T2 = T*T1;
                % Find 6dof from T and Store it in an array
                [posX, posY, posZ, rote1, rote2, rote3] =...
                    vcdp.Tmat2Cartesian(T2);
                
                O(itr6,2:7) = [posX, posY, posZ, (rote1 + AngleOffset(1)),...
                    (rote2 +AngleOffset(2)) , (rote3+ AngleOffset(3))];
            end
            
            
        end
        %%---------------------------------------------------------------%%
        
        %%datasetStatExtraction ------------------------%
        function [dataset] = datasetStatExtraction(fileName)
            %datasetStatExtraction Summary of this function goes here
            %   Detailed explanation goes here
            dataset = struct();
            load(strcat("results/",fileName,".mat"));
            
            t = transformedViveData(:,1);
            P = transformedViveData(:,2:4);
            C = comauData(:,2:4);
            V = viveData(:,2:4);
            N  = size(t,1);
            
            % Time lag
            [rel,~]= xcorr(C(:,1),P(:,1),'unbiased');
            dataset.time_lag = max(rel);
            
            [C_vel, ~] = vcdp.calculateVelAcc(comauData);
            C_vel = C_vel(:,1:3);
            
            [P_vel, ~] = vcdp.calculateVelAcc(transformedViveData);
            P_vel = P_vel(:,1:3);
            dataset.velocity = P_vel;
            % runtime
            dataset.runtime  = max(t); % in seconds
            
            % distance covered calculation by the trajectory
            d2 = sqrt(diff(C(:,1)).^2 + diff(C(:,2)).^2 +diff(C(:,3)).^2 );
            dataset.total_distance_covered = sum(d2);
            
            % max velcoity
            dataset.max_velocity = max(C_vel);
            
            % mean absolute error
            dataset.mae = vcdp.calMAE(C,P);
            
            % Standard deviation of error
            error  = C-P;
            dataset.std_error = std(error);
            dist_error  = sqrt((C(:,1)-P(:,1)).^2 ...
                + (C(:,2)-P(:,2)).^2 + (C(:,3)-P(:,3)).^2 );
            dataset.std_disterror = std(dist_error,0,'all');
            
            % RMSE
            dataset.rmse_error = rms(error);
            dataset.rmse_disterror = rms(dist_error);
            
            % Max error velocity
            error_vel = C_vel - P_vel;
            dataset.max_vel_error  = max(error_vel);
            dataset.mave = max(sqrt((C_vel(:,1)-P_vel(:,1)).^2 ...
                + (C_vel(:,2)-P_vel(:,2)).^2 + (C_vel(:,3)-P_vel(:,3)).^2 ));
            
            %%FOR PLOTTING
            dataset.dist_error = dist_error;
            dataset.error = error;
            %
            % figure()
            % plot3(P(:,1),P(:,2),P(:,3),'r'); hold on;
            % plot3(C(:,1),C(:,2),C(:,3),'b.'); hold on;
            % axis equal; grid on;
            % xlabel('X [meters]'); ylabel('Y [meters]'); zlabel('Z [meters]');
            
            disp(max(error))
            disp(min(error))
        end
        
        function [outArray] = centralisedNumericalDiff(inArray)
            %centralisedNumericalDiff creates centralised numberical
            %differentiation.
            %             x[k+1] - x[k-1]
            % x_dot [k] = ---------------- = (x[k+1] - x[k-1])/2
            %
            
            for k = 2 : length(inArray)-1
                theDiff = inArray(k+1) - inArray(k-1);
                outArray(k-1) = (theDiff)/2;
            end
            outArray = transpose(outArray);
        end
        
        function [vel, acc] = calculateVelAcc(data,visualisePlot)
            %PlotVelAccProcessedData Function for calculating and ploting
            %velcity and acceleration. Circular numerical differention was used.
            %   Input should be processed: have same
            %length of data as well as same
            %   sampling frequency
            
            %Example usage
            % %%load('results/1579678802971065100.mat')
            %
            % data = viveData;
            % visualisePlot = true;
            % PlotVelAccProcessedData(data,visualisePlot);
            
            
            if nargin<2
                visualisePlot = false;
            end
            
            tdiff  = vcdp.centralisedNumericalDiff(data(:,1));
            %%Velocity calculation
            disp("RAW VELOCITY")
            velX  = vcdp.centralisedNumericalDiff(data(:,2))./tdiff;
            fprintf('Max velX = %f\t Min velX = %f\n', max(velX), min(velX))
            velY  = vcdp.centralisedNumericalDiff(data(:,3))./tdiff;
            fprintf('Max velY = %f\t Min velY = %f\n', max(velY), min(velY))
            velZ  = vcdp.centralisedNumericalDiff(data(:,4))./tdiff;
            fprintf('Max velZ = %f\t Min velZ = %f\n', max(velZ), min(velZ))
            vele1 = vcdp.centralisedNumericalDiff(data(:,5))./tdiff;
            fprintf('Max vele1 = %f\t Min vele1 = %f\n', max(vele1), min(vele1))
            vele2 = vcdp.centralisedNumericalDiff(data(:,6))./tdiff;
            fprintf('Max vele2 = %f\t Min vele2 = %f\n', max(vele2), min(vele2))
            vele3 = vcdp.centralisedNumericalDiff(data(:,7))./tdiff;
            fprintf('Max vele3 = %f\t Min vele3 = %f\n\n', max(vele3), min(vele3))
            
            vel = [velX, velY, velZ, vele1, vele2, vele3];
            
            %%Accleration calculation
            disp("RAW ACCELERATION")
            accX  = vcdp.centralisedNumericalDiff(velX)./tdiff(2:end-1);
            fprintf('Max accX = %f\t Min accX = %f\n', max(accX),min(accX))
            accY  = vcdp.centralisedNumericalDiff(velY)./tdiff(2:end-1);
            fprintf('Max accY = %f\t Min accY = %f\n', max(accY), min(accY))
            accZ  = vcdp.centralisedNumericalDiff(velZ)./tdiff(2:end-1);
            fprintf('Max accZ = %f\t Min accZ = %f\n', max(accZ), min(accZ))
            acce1  = vcdp.centralisedNumericalDiff(vele1)./tdiff(2:end-1);
            fprintf('Max acce1 = %f\t Min acce1 = %f\n', max(acce1), min(acce1))
            acce2  = vcdp.centralisedNumericalDiff(vele2)./tdiff(2:end-1);
            fprintf('Max acce2 = %f\t Min acce2 = %f\n', max(acce2), min(acce2))
            acce3  = vcdp.centralisedNumericalDiff(vele3)./tdiff(2:end-1);
            fprintf('Max acce3 = %f\t Min acce3 = %f\n', max(acce3), min(acce3))
            acc = [accX, accY, accZ, acce1,acce2, acce3 ];
            % run figure_configuration_IEEE_standard
            if visualisePlot == true
                
                % Position plot
                figure(); grid on;
                h1 = subplot(3,1,1);
                scatter(data(:,1) , data(:,2),'r.'); hold on;
                plot(data(:,1) , data(:,2),'k'); grid on;
                title('Position in X axis')
                
                h2 =subplot(3,1,2);
                scatter(data(:,1) , data(:,3) ,'g.'); hold on;
                plot(data(:,1) , data(:,3),'k'); grid on;
                title('Position in Y axis')
                
                h3 =subplot(3,1,3);
                scatter(data(:,1) , data(:,4) ,'g.'); hold on;
                plot(data(:,1) , data(:,4),'k'); grid on;
                title('Position in Z axis')
                
                p1=get(h1,'position');
                p2=get(h2,'position');
                p3=get(h3,'position');
                height= (p1(1)+p2(3)-p3(1));
                width=p2(1)+p2(3)-p3(1);
                h5=axes('position',[p3(1) p3(2) width height],'visible','off');
                h5.XLabel.Visible='on';
                h5.YLabel.Visible='on';
                axes(h5)
                ylabel('Position [m]')
                xlabel('Timestamp [seconds]')
                
                
                % Orientation plot
                figure(); grid on;
                h1 = subplot(3,1,1);
                scatter(data(:,1) , data(:,5),'r.'); hold on;
                plot(data(:,1) , data(:,5),'k'); grid on;
                title('Orienation in Z axis')
                
                h2 =subplot(3,1,2);
                scatter(data(:,1) , data(:,6) ,'g.'); hold on;
                plot(data(:,1) , data(:,6),'k'); grid on;
                title('Orientation in Y axis')
                
                h3 =subplot(3,1,3);
                scatter(data(:,1) , data(:,7) ,'g.'); hold on;
                plot(data(:,1) , data(:,7),'k'); grid on;
                title('Orientation in Z axis')
                
                p1=get(h1,'position');
                p2=get(h2,'position');
                p3=get(h3,'position');
                height= (p1(1)+p2(3)-p3(1));
                width=p2(1)+p2(3)-p3(1);
                h5=axes('position',[p3(1) p3(2) width height],'visible','off');
                h5.XLabel.Visible='on';
                h5.YLabel.Visible='on';
                axes(h5)
                ylabel('Orientation [deg]')
                xlabel('Timestamp [seconds]')
                
                % Linear velcoity plot
                figure(); grid on;
                h1 = subplot(3,1,1);
                scatter(data(2:end-1,1) , velX ,'r.'); hold on;
                plot(data(2:end-1,1) , velX,'k'); grid on;
                title('Linear velocity in X axis')
                
                h2 =subplot(3,1,2);
                scatter(data(2:end-1,1) , velY ,'g.'); hold on;
                plot(data(2:end-1,1) , velY,'k'); grid on;
                title('Linear velocity in Y axis')
                
                h3 =subplot(3,1,3);
                scatter(data(2:end-1,1) , velZ ,'g.'); hold on;
                plot(data(2:end-1,1) , velZ,'k'); grid on;
                title('Linear velocity in Z axis')
                
                p1=get(h1,'position');
                p2=get(h2,'position');
                p3=get(h3,'position');
                height= (p1(1)+p2(3)-p3(1));
                width=p2(1)+p2(3)-p3(1);
                h5=axes('position',[p3(1) p3(2) width height],'visible','off');
                h5.XLabel.Visible='on';
                h5.YLabel.Visible='on';
                axes(h5)
                ylabel('Linear Velocity [m/s]')
                xlabel('Timestamp [seconds]')
                
                
                % Linear acceleration plot
                figure();grid on;
                h1 = subplot(3,1,1);
                scatter(data(3:end-2,1) , accX ,'r.'); hold on;
                plot(data(3:end-2,1) , accX,'k'); grid on;
                title('Linear acceleration: X axis')
                
                
                h2 = subplot(3,1,2);
                scatter(data(3:end-2,1) , accY ,'g.'); hold on;
                plot(data(3:end-2,1) , accY,'k'); grid on;
                title('Linear acceleration: Y axis')
                
                
                h3 = subplot(3,1,3);
                scatter(data(3:end-2,1) , accZ ,'g.'); hold on;
                plot(data(3:end-2,1) , accZ,'k'); grid on;
                title('Linear acceleration: Z axis')
                
                p1=get(h1,'position');
                p2=get(h2,'position');
                p3=get(h3,'position');
                height= (p1(1)+p2(3)-p3(1));
                width=p2(1)+p2(3)-p3(1);
                h5=axes('position',[p3(1) p3(2) width height],'visible','off');
                h5.XLabel.Visible='on';
                h5.YLabel.Visible='on';
                axes(h5)
                ylabel('Linear acceleration [m/s^2]')
                xlabel('Timestamp [seconds]')
                
                
                % Angular velocity plot
                figure();grid on;
                h1=subplot(3,1,1);
                scatter(data(2:end-1,1) , vele1 ,'r.'); hold on;
                plot(data(2:end-1,1) , vele1,'k'); grid on;
                title('Angular velocity: Z1 axis[ZYZ_ Euler Convention]')
                
                h2=subplot(3,1,2);
                scatter(data(2:end-1,1) , vele2 ,'g.'); hold on;
                plot(data(2:end-1,1) , vele2,'k'); grid on;
                title('Angular velocity: Y axis[ZYZ_ Euler Convention]')
                
                
                h3=subplot(3,1,3);
                scatter(data(2:end-1,1) , vele3 ,'g.'); hold on;
                plot(data(2:end-1,1) , vele3,'k'); grid on;
                title('Angular velocity: Z2 axis[ZYZ_ Euler Convention]')
                
                p1=get(h1,'position');
                p2=get(h2,'position');
                p3=get(h3,'position');
                height= (p1(1)+p2(3)-p3(1));
                width=p2(1)+p2(3)-p3(1);
                h5=axes('position',[p3(1) p3(2) width height],'visible','off');
                h5.XLabel.Visible='on';
                h5.YLabel.Visible='on';
                axes(h5)
                ylabel('Angular velocity [deg/s]')
                xlabel('Timestamp [seconds]')
                
                % Angular acceleration plot
                figure();grid on;
                h1=subplot(3,1,1);
                scatter(data(3:end-2,1) , acce1 ,'r.'); hold on;
                plot(data(3:end-2,1) , acce1,'k'); grid on;
                title('Angular acceleration: Z1 axis[ZYZ_ Euler Convention]')
                
                h2=subplot(3,1,2);
                scatter(data(3:end-2,1) , acce2 ,'g.'); hold on;
                plot(data(3:end-2,1) , acce2,'k'); grid on;
                title('Linear acceleration: Y axis[ZYZ_ Euler Convention]')
                
                h3=subplot(3,1,3);
                scatter(data(3:end-2,1) , acce3 ,'g.'); hold on;
                plot(data(3:end-2,1) , acce3,'k'); grid on;
                title('Linear acceleration: Z2 axis[ZYZ_ Euler Convention]')
                
                p1=get(h1,'position');
                p2=get(h2,'position');
                p3=get(h3,'position');
                height= (p1(1)+p2(3)-p3(1));
                width=p2(1)+p2(3)-p3(1);
                h5=axes('position',[p3(1) p3(2) width height],'visible','off');
                h5.XLabel.Visible='on';
                h5.YLabel.Visible='on';
                axes(h5)
                ylabel('Angular acceleration [degrees/s^2]')
                xlabel('Timestamp [seconds]')
                
            end
            
        end
        
        function mae = calMAE(orgSig,recSig,varargin)
            %%This function calculates the mae of a signal with reference
            %to original signal.mae can be calculated for 1-D/2-D/3-D signals.
            %%-----------------------------------------------------------%%
            % output: mae-> mae (mean absolute error)
            % input:
            %   orgSig-> original 1-D/2-D/3-D signal (or reference signal)
            %   recSig-> reconstructed (1-D/2-D/3-D) signal/ signal obtained
            %     from the experiment/ signal, of which mae is to be
            %     calculated with reference to original signal.
            %   boun-> boun is the boundary left at the corners for the
            %      mae calculation.  default value = 0
            
            if isempty(varargin)
                boun = 0;
            else boun = varargin{1};
            end
            
            if size(orgSig,2)==1       % if signal is 1-D
                orgSig = orgSig(boun+1:end-boun,:);
                recSig = recSig(boun+1:end-boun,:);
            else                       % if signal is 2-D or 3-D
                orgSig = orgSig(boun+1:end-boun,boun+1:end-boun,:);
                recSig = recSig(boun+1:end-boun,boun+1:end-boun,:);
            end
            
            absErr = norm(orgSig(:)-recSig(:),1);
            mae = absErr/length(orgSig(:));
        end
        %%---------------------------------------------------------------%%
        
    end
end


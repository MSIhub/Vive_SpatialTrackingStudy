clear; close all; clc;
velRepo = ["V1_0", "V0_5", "V0_4", "V0_3", "V0_25", "V0_2", "V0_185",...
    "V0_175", "V0_150", "V0_135", "V0_125", "V0_1", "V0_05", "V0_010"];


for itr0 =1:1:length(velRepo)
    velName = velRepo(itr0);
    % final results in mm and deg
    data = struct();
    % data.I1 = load("Results\DA_C_Init_Itrn1.mat");
    % data.I2 = load("Results\DA_C_Init_Itrn2.mat");
    % data.I3 = load("Results\DA_C_Init_Itrn3.mat");
    data.XO1 = load(['Results\DA_C_', char(velName),'_XO1.mat']);
    data.YO1 = load(['Results\DA_C_', char(velName),'_YO1.mat']);
    data.XO2 = load(['Results\DA_C_', char(velName),'_XO2.mat']);
    data.YO2 = load(['Results\DA_C_', char(velName),'_YO2.mat']);
    data.XO3 = load(['Results\DA_C_', char(velName),'_XO3.mat']);
    data.YO3 = load(['Results\DA_C_', char(velName),'_YO3.mat']);
    
    % velName = "HT";
    % data.SS1 = load(['Results\DA_C_', char(velName),'_SS1.mat']);
    % data.SM1 = load(['Results\DA_C_', char(velName),'_SM1.mat']);
    % data.SF1 = load(['Results\DA_C_', char(velName),'_SF1.mat']);
    % data.PS1 = load(['Results\DA_C_', char(velName),'_PS1.mat']);
    % data.PM1 = load(['Results\DA_C_', char(velName),'_PM1.mat']);
    % data.PF1 = load(['Results\DA_C_', char(velName),'_PF1.mat']);
    % data.PM2 = load(['Results\DA_C_', char(velName),'_PM2.mat']);
    
    
    fields = fieldnames(data);
    
    resultFile = ['Results\DA_C_', char(velName),'.mat'];
    
    if velName == "HT"
        resultFile = ['Results\DA_C_', char(fields(1)),'.mat'];
    end
    
    nT= [];
    theta = [];
    vel =[];
    timestamp = [];
    
    
    for itr1 = 1:1:length(fields)
        nT = [nT; data.(fields{itr1}).nT * 1000]; % m to mm
        theta = [theta; (data.(fields{itr1}).theta) *(180/pi)]; % rad to deg
        vel = [vel; data.(fields{itr1}).vel * 1000]; % m/s to mm/s
        timestamp = [timestamp; data.(fields{itr1}).timestamp];
    end
    
    Vel_avg = mean(vel);
    Vel_max = max(vel);
    
    % %% INIT Results %%%
    % nT_m= mean(nT)
    % theta_m = median(theta)
    %
    % figure()
    % hold on
    % plot(theta)
    % plot(theta_m*ones(size(theta)))
    
    
    rm_ind_v = find(vel(:,1) > 1600);
    temp = vel(rm_ind_v,:);
    vel = vel(~ismember(vel(:,1),temp(:,1)),:);
    nT = nT(~ismember(vel(:,1),temp(:,1)),:);
    theta = theta(~ismember(vel(:,1),temp(:,1)),:);
    
    Vel_avg = mean(vel);
    Vel_max = max(vel);
    
    %% Error statistic using Reference System data
    nT_ref = 345.9; %mm
    theta_ref = 179.907;%deg
    
    %V0_2
    if velName == "V0_2"
        nT(18550:18750,:) =[];
        theta(18550:18750,:) =[];
        vel(18550:18750,:) =[];
    end
    
    %V0_150
    if velName == "V0_150"
        nT(29450:29800,:) =[];
        theta(29450:29800,:) =[];
        vel(29450:29800,:) =[];
    end
    
    %V0_1
    if velName == "V0_1"
        nT(36600:36700,:) =[]; nT(5600:5700,:) =[]; nT(52100:52400,:) =[];
        theta(36600:36700,:) =[];theta(5600:5700,:) =[]; theta(52100:52400,:) =[];
        vel(36600:36700,:) =[]; vel(5600:5700,:) =[]; vel(52100:52400,:) =[];
    end
    %V0_4
    if velName == "V0_4"
        nT(10500:10800,:) =[];
        theta(10500:10800,:) =[];
        vel(10500:10800,:) =[];
    end
    
    dd = 3;% round decimal digit
    errorStat = struct();
    e_p = abs(nT - nT_ref);
    e_o = abs(theta_ref - theta) ;
    
    %V0_010
    if velName == "V0_010"
        rm_ind = find(e_p(:,1) > 12.856);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 1.5);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    errorStat.e_p = e_p;
    errorStat.rsme_p = round(sqrt(sum(e_p.^2)/length(e_p)), dd);
    errorStat.maxe_p = round(max(e_p), dd);
    E_p = sort(e_p);
    errorStat.E50_p = round(prctile(E_p,50), dd);
    errorStat.E95_p = round(prctile(E_p,95), dd);
    errorStat.E99_7_p = round(prctile(E_p,99.7), dd);
    errorStat.ebar_p = sum(e_p)/length(e_p);
    errorStat.s_sqr_p = sum((e_p - errorStat.ebar_p ).^2) / (length(e_p) -1);
    
    errorStat.e_o = e_o;
    errorStat.rsme_o = round(sqrt(sum(e_o.^2)/length(e_o)), dd);
    errorStat.maxe_o = round(max(e_o), dd);
    E_o = sort(e_o);
    errorStat.E50_o = round(prctile(E_o,50), dd);
    errorStat.E95_o = round(prctile(E_o,95), dd);
    errorStat.E99_7_o = round(prctile(E_o,99.7), dd);
    errorStat.ebar_o = sum(e_o)/length(e_o);
    errorStat.s_sqr_o = sum((e_o - errorStat.ebar_o ).^2) / (length(e_o) -1);
    %% Repeatability without Reference system
    repeatStat = struct();
    
    d_p = abs(nT - mean(nT));
    repeatStat.rsmd_p = round(sqrt(sum(d_p.^2)/length(d_p)), dd);
    repeatStat.maxd_p = round(max(d_p), dd);
    D_p = sort(d_p);
    repeatStat.D50_p = round(prctile(D_p,50), dd);
    repeatStat.D95_p = round(prctile(D_p,95), dd);
    repeatStat.D99_7_p = round(prctile(D_p,99.7), dd);
    
    
    d_o = abs(theta - mean(theta)) ;
    repeatStat.rsmd_o = round(sqrt(sum(d_o.^2)/length(d_o)), dd);
    repeatStat.maxd_o = round(max(d_o), dd);
    D_o = sort(d_o);
    repeatStat.D50_o = round(prctile(D_o,50), dd);
    repeatStat.D95_o = round(prctile(D_o,95), dd);
    repeatStat.D99_7_o = round(prctile(D_o,99.7), dd);
    
    %% Saving results to a txt file
    save(resultFile,'errorStat', 'repeatStat', 'vel', 'Vel_avg', 'Vel_max');
    
    
end


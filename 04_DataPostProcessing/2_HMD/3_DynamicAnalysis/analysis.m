clear; close all; clc;
velRepo = ["V1_0", "V0_5", "V0_4", "V0_3", "V0_25", "V0_2", "V0_185",...
    "V0_175", "V0_150", "V0_135", "V0_125", "V0_1", "V0_050", "V0_010"];


for itr0 =1:1:length(velRepo)
    velName = velRepo(itr0);
    % final results in mm and deg
    data = struct();
    % data.I1 = load("Results\DA_T_Init_I1.mat");
    % data.I2 = load("Results\DA_T_Init_I2.mat");
    % data.I3 = load("Results\DA_T_Init_I3.mat");
    % velName = "V0_010";
    data.XO1 = load(['Results\DA_H_', char(velName),'_XO1.mat']);
    data.YO1 = load(['Results\DA_H_', char(velName),'_YO1.mat']);
    data.XO2 = load(['Results\DA_H_', char(velName),'_XO2.mat']);
    data.YO2 = load(['Results\DA_H_', char(velName),'_YO2.mat']);
    data.XO3 = load(['Results\DA_H_', char(velName),'_XO3.mat']);
    data.YO3 = load(['Results\DA_H_', char(velName),'_YO3.mat']);
    
    % velName = "HT";
    % repoName = ["SS1"];%[ "SM1", "SF1", "PS1", "PM1", "PF1", "PM2", "PF2"];
    % data.SS1 = load(['Results\DA_H_', char(velName),'_SS1.mat']);
    % data.SM1 = load(['Results\DA_H_', char(velName),'_SM1.mat']);
    % data.SF1 = load(['Results\DA_H_', char(velName),'_SF1.mat']);
    % data.PS1 = load(['Results\DA_H_', char(velName),'_PS1.mat']);
    % data.PM1 = load(['Results\DA_H_', char(velName),'_PM1.mat']);
    % data.PF1 = load(['Results\DA_H_', char(velName),'_PF1.mat']);
    % data.PM2 = load(['Results\DA_H_', char(velName),'_PM2.mat']);
    % data.PF2 = load(['Results\DA_H_', char(velName),'_PF2.mat']);
    fields = fieldnames(data);
    
    resultFile = ['Results\DA_H_', char(velName),'.mat'];
    
    if velName == "HT"
        resultFile = ['Results\DA_H_', char(fields(1)),'.mat'];
    end
    
    e_p= [];
    e_o = [];
    vel =[];
    
    
    for itr1 = 1:1:length(fields)
        e_p = [e_p; data.(fields{itr1}).DA_H_Stat.e_p * 1000]; % m to mm
        e_o = [e_o; (data.(fields{itr1}).DA_H_Stat.e_o) *(180/pi)]; % rad to deg
        vel = [vel; data.(fields{itr1}).vel * 1000]; % m/s to mm/s
    end
    
    
      
    rm_ind_v = find(vel(:,1) > 1600);
    temp = vel(rm_ind_v,:);
    vel = vel(~ismember(vel(:,1),temp(:,1)),:);
    e_p = e_p(~ismember(vel(:,1),temp(:,1)),:);
    e_o = e_o(~ismember(vel(:,1),temp(:,1)),:);
    
    Vel_avg = mean(vel);
    Vel_max = max(vel);
    
    % if fieldnames(data) == "PF1"
    %     e_o = abs(e_o - mode(e_o));
    % end
    
    
    if velName == "V0_010"
        rm_ind = find(e_p(:,1) > 7.288);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 1.845);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    if velName == "V0_050"
        rm_ind = find(e_p(:,1) > 11.11);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 1.845);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    
    if velName == "V0_1"
        rm_ind = find(e_p(:,1) > 18.29);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 1.845);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    
    if velName == "V0_125"
        rm_ind = find(e_p(:,1) > 22.03);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 1.845);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    if velName == "V0_135"
        rm_ind = find(e_p(:,1) > 25.69);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 1.649);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    if velName == "V0_150"
        rm_ind = find(e_p(:,1) > 27.77);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 1.649);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    if velName == "V0_175"
        rm_ind = find(e_p(:,1) > 28.11);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 1.85);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    if velName == "V0_185"
        rm_ind = find(e_p(:,1) > 31.45);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 1.75);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    if velName == "V0_2"
        rm_ind = find(e_p(:,1) > 33.66);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 1.74);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    if velName == "V0_25"
        rm_ind = find(e_p(:,1) > 39.48);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 1.85);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    if velName == "V0_3"
        rm_ind = find(e_p(:,1) > 47.74);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 1.85);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    
    if velName == "V0_4"
        rm_ind = find(e_p(:,1) > 62.76);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 2);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    if velName == "V0_5"
        rm_ind = find(e_p(:,1) > 75.13);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 2);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    if velName == "V1_0"
        rm_ind = find(e_p(:,1) > 102.8);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 3);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    
    if velName == "V1_5"
        rm_ind = find(e_p(:,1) > 120.8);
        temp = e_p(rm_ind,:);
        e_p = e_p(~ismember(e_p(:,1),temp(:,1)),:);
        vel = vel(~ismember(e_p(:,1),temp(:,1)),:);
        
        rm_ind_o = find(e_o(:,1) > 4);
        temp_o = e_o(rm_ind_o,:);
        e_o = e_o(~ismember(e_o(:,1),temp_o(:,1)),:);
    end
    

    %% Error statistic using Reference System data
    
    dd = 3;% round decimal digit
    errorStat = struct();
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
    
    %% Saving results to a txt file
    save(resultFile,'errorStat', 'vel', 'Vel_avg', 'Vel_max');
end
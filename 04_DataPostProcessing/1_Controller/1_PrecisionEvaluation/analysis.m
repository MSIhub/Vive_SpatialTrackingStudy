clear; clc; close all;
%-----------------------------------------%
fileName = 'Results/PointsCombined.mat';
data = load(fileName);
fields = fieldnames(data);
PE_C_Stat_PT = struct();
for itr1 = 1:1:length(fields)
    PE_C_Stat_PT.(fields{itr1}).nT = zeros(length(data.(fields{itr1}).V),1);
    PE_C_Stat_PT.(fields{itr1}).theta = zeros(length(data.(fields{itr1}).V),1);
    for itr2 = 1:1:length(data.(fields{itr1}).V)
        PE_C_Stat_PT.(fields{itr1}).nT(itr2) = norm([data.(fields{itr1}).V(itr2,5), data.(fields{itr1}).V(itr2,9),data.(fields{itr1}).V(itr2,13)] .*1000 ); % mm
        R = [data.(fields{itr1}).V(itr2,2), data.(fields{itr1}).V(itr2,3),data.(fields{itr1}).V(itr2,4);...
            data.(fields{itr1}).V(itr2,6), data.(fields{itr1}).V(itr2,7),data.(fields{itr1}).V(itr2,8);...
            data.(fields{itr1}).V(itr2,10), data.(fields{itr1}).V(itr2,11),data.(fields{itr1}).V(itr2,12)];
        PE_C_Stat_PT.(fields{itr1}).theta(itr2) =acos((trace(R)-1)/2) * (180/pi); % angle axis representation [deg]
    end
    
    %Repeatability without Reference system
    PE_C_Stat_PT.(fields{itr1}).d_p = abs(PE_C_Stat_PT.(fields{itr1}).nT - mean(PE_C_Stat_PT.(fields{itr1}).nT));
    PE_C_Stat_PT.(fields{itr1}).rsmd_p = sqrt(sum(PE_C_Stat_PT.(fields{itr1}).d_p.^2)/length(PE_C_Stat_PT.(fields{itr1}).d_p));
    PE_C_Stat_PT.(fields{itr1}).maxd_p = max(PE_C_Stat_PT.(fields{itr1}).d_p);
    D_p = sort(PE_C_Stat_PT.(fields{itr1}).d_p);
    PE_C_Stat_PT.(fields{itr1}).D50_p = prctile(D_p,50);
    PE_C_Stat_PT.(fields{itr1}).D95_p = prctile(D_p,95);
    PE_C_Stat_PT.(fields{itr1}).D99_7_p = prctile(D_p,99.7);
    
    
    PE_C_Stat_PT.(fields{itr1}).d_o = abs(PE_C_Stat_PT.(fields{itr1}).theta - mean(PE_C_Stat_PT.(fields{itr1}).theta));
    PE_C_Stat_PT.(fields{itr1}).rsmd_o = sqrt(sum(PE_C_Stat_PT.(fields{itr1}).d_o.^2)/length(PE_C_Stat_PT.(fields{itr1}).d_o));
    PE_C_Stat_PT.(fields{itr1}).maxd_o = max(PE_C_Stat_PT.(fields{itr1}).d_o);
    D_o = sort(PE_C_Stat_PT.(fields{itr1}).d_o);
    PE_C_Stat_PT.(fields{itr1}).D50_o = prctile(D_o,50);
    PE_C_Stat_PT.(fields{itr1}).D95_o = prctile(D_o,95);
    PE_C_Stat_PT.(fields{itr1}).D99_7_o = prctile(D_o,99.7);
end

% Box plot
for itr3 = 1:1:length(fields)
    combo_d_p(1:length(PE_C_Stat_PT.(fields{itr3}).d_p),itr3) = PE_C_Stat_PT.(fields{itr3}).d_p;
    combo_d_o(1:length(PE_C_Stat_PT.(fields{itr3}).d_o),itr3) = PE_C_Stat_PT.(fields{itr3}).d_o;
    %boxplot(combo_d_p);
%    boxplot(combo_d_o,'PlotStyle','compact')
end

anova1(combo_d_p);
anova1(combo_d_o);


% Combo data table
PE_C_Stat_Combo.d_p = reshape(combo_d_p,[numel(combo_d_p),1]);
PE_C_Stat_Combo.rsmd_p = sqrt(sum(PE_C_Stat_Combo.d_p .^2)/length(PE_C_Stat_Combo.d_p ));
PE_C_Stat_Combo.maxd_p = max(PE_C_Stat_Combo.d_p);
combo_D_p = sort(PE_C_Stat_Combo.d_p );
PE_C_Stat_Combo.D50_p = prctile(combo_D_p,50);
PE_C_Stat_Combo.D95_p = prctile(combo_D_p,95);
PE_C_Stat_Combo.D99_7_p = prctile(combo_D_p,99.7);

PE_C_Stat_Combo.d_o = reshape(combo_d_o,[numel(combo_d_o),1]);
PE_C_Stat_Combo.rsmd_o = sqrt(sum(PE_C_Stat_Combo.d_o.^2)/length(PE_C_Stat_Combo.d_o));
PE_C_Stat_Combo.maxd_o = max(PE_C_Stat_Combo.d_o);
combo_D_o = sort(PE_C_Stat_Combo.d_o);
PE_C_Stat_Combo.D50_o = prctile(combo_D_o,50);
PE_C_Stat_Combo.D95_o = prctile(combo_D_o,95);
PE_C_Stat_Combo.D99_7_o = prctile(combo_D_o,99.7);
% Saving to mat file
resultFile = ['Results/PE_C_Stat.mat'];
save(resultFile,'PE_C_Stat_PT', 'PE_C_Stat_Combo');
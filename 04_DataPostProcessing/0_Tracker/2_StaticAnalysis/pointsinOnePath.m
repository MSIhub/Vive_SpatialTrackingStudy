function  [out] = pointsinOnePath(C_in,V_in,Points)

C = C_in(:,2:7);
out = struct();

fields = fieldnames(Points);

for ff = 1:1:length(fields)
    
    P = Points.(fields{ff});
    
    [indA1,~, ~] = find(round(C(:,1), 4)== P(1,1));
    [indA2,~, ~] = find(round(C(:,2), 4)== P(1,2));
    [indA3,~, ~] = find(round(C(:,3), 4)== P(1,3));
    
    if length(indA1)>length(indA2)
        indA = indA1;
        iA_ = setdiff(indA,indA2);
    else
        indA = indA2;
        iA_ = setdiff(indA,indA1);
    end
    [~,interInd]=ismember(iA_,indA);
    indA(interInd) = [];
    iA2_ = setdiff(indA,indA3);
    if ~isempty(iA2_)
        idx = ismember(indA, iA2_, 'rows');
        c = 1:size(indA, 1);
        d = c(idx);
        indA(d) = [];
    end
    
    nA = numel(indA);
    start = round(nA*0.2);
    stop = nA-round(nA*0.2);
    indexA = indA(start:stop); % ignoring the time offset
    % t_A = t(indexA);
    C_A = C_in(indexA, :);
    V_A = V_in(indexA, :);
    
    
    % Remove Zero data (Usually happens when the Vive data collection starts latter than the Comau)
    % Wont affect the results as we simply remove the non recorded data
    isZeroData = zeros(size(V_A,1),1);
    for itr1 = 1:1:size(V_A,1)
        if (V_A(itr1,2)== 0 && V_A(itr1,3)==0 && V_A(itr1,4)==0 && V_A(itr1,5)==0 && V_A(itr1,6)==0 && V_A(itr1,7)==0)
            isZeroData(itr1) = 1;
        end
    end
    
    C_A(isZeroData==1,:) = [];
    V_A(isZeroData==1,:) = [];
    rml = round(0.3* length(C_A));
    C_A(rml:end-rml,:) = [];
    V_A(rml:end-rml,:) = [];
    
    out.(fields{ff}).C = C_A;
    out.(fields{ff}).V = V_A;
    
end
end
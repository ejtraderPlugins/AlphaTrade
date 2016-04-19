function ParseTmp2CurrHolding_xuntou(AccountInfo, i)
times = clock;
ndate = times(1) * 1e4 + times(2) * 1e2 + times(3);
date = double2str(ndate);
path = [AccountInfo{6}{1} AccountInfo{2}{i} '\'];
if i == 1 || i == 2
    sourceFile = [path date '\Stock_Holdings_' num2str(i) '.txt'];
else
    sourceFile = [path date '\Stock_Holdings.txt'];
end
destDir = [AccountInfo{6}{2} AccountInfo{2}{i} '\'];
if ~exist(destDir, 'dir')
    mkdir(destDir);
end
destFile = [destDir 'current_holdings_' date '.txt'];

%% parse holding log file
unit = AccountInfo{7}(i);
fid_s = fopen(sourceFile, 'r');
if fid_s > 0
    rawData = textscan(fid_s, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s','delimiter','\t');
    numOfInst = size(rawData{1,4},1) - 1;
    holding = zeros(numOfInst, 3);
    tmp = str2double(rawData{1,4});%ticker
    holding(:,1) = tmp(2:end,1);
    tmp = str2double(rawData{1,6});%holding
    holding(:,2) = tmp(2:end,1) * unit;
    tmp = str2double(rawData{1,15});%available holding
    holding(:,3) = tmp(2:end,1);

    for k = 1:size(holding,2)
        holding(isnan(holding(:,k)),:) = [];
    end
    fclose(fid_s);
end

if exist('holding','var')
    if ~isempty(holding)
        fid_d = fopen(destFile,'w');
        fprintf(fid_d, [repmat('%15d\t',1,size(holding,2)), '\n'], holding');
        fclose(fid_d);
    end
end
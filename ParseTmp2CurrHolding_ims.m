function ParseTmp2CurrHolding_ims(AccountInfo, id)
global fid_log

numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin to parse stock holding file. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);

path_source = [AccountInfo{ai}.ACCOUNTPATH AccountInfo{ai}.NAME '\'];
path_dest     = [AccountInfo{ai}.ACCOUNTPATH  AccountInfo{ai}.NAME '\'];
sourceFile    = [path_source 'stock_holding.txt'];
destFile        = [path_dest 'current_holding.txt'];
unit = str2double(AccountInfo{ai}.UNIT);

%% parse holding log file
fid_s = fopen(sourceFile, 'r');
if fid_s > 0
    [idate, itime] = GetDateTimeNum();
    fprintf(fid_log, '--->>> %s_%s,\tBegin to parse holding file. file = %s.\n', num2str(idate), num2str(itime), sourceFile);
    
    rawData = textscan(fid_s, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s','delimiter',',');
    numOfInst = size(rawData{1,1},1) - 1;
    holding = zeros(numOfInst, 3);
    tmp = str2double(rawData{1,2});%ticker
    holding(:,1) = tmp(2:end,1);
    tmp = str2double(rawData{1,6});%holding
    holding(:,2) = tmp(2:end,1) * unit;
    tmp = str2double(rawData{1,9});%available holding
    holding(:,3) = tmp(2:end,1);

    for k = 1:size(holding,2)
        holding(isnan(holding(:,k)),:) = [];
    end
    fclose(fid_s);    
else
    [idate, itime] = GetDateTimeNum();
    fprintf(fid_log, '--->>> %s_%s,\tError when open holding file. file = %s.\n', num2str(idate), num2str(itime), sourceFile);
end

if exist(path_dest,'dir')
else
    mkdir(path_dest);
end
if exist('holding','var')
    if ~isempty(holding)
        fid_d = fopen(destFile,'w');
        fprintf(fid_d, [repmat('%15d\t',1,size(holding,2)), '\n'], holding');
        fclose(fid_d);
    end
end

%% copy file to history direction
[idate, itime] = GetDateTimeNum();
dst_sourceFile    = [path_source 'HistoricalLog\stock_holding_' num2str(idate) '_' num2str(itime) '.txt'];
dst_destFile        = [path_dest '\HistoricalCurrentHolding\current_holding_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(sourceFile, dst_sourceFile);
CopyFile2HistoryDir(destFile, dst_destFile);

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd to parse stock holding file. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
function ParseTmp2CurrHolding_winner(AccountInfo, i)
times = clock;
ndate = times(1) * 1e4 + times(2) * 1e2 + times(3);
sdate = num2str(ndate);
path = [AccountInfo{i}.LOGPATH AccountInfo{i}.NAME '\'];
sourceFile = [path sdate '\stock_holdings.csv'];
destFile = [path sdate '\current_holdings.txt'];

%% parse holding log file
unit = AccountInfo{i}.UNIT;
fid_s = fopen(sourceFile, 'r');
if fid_s > 0
    rawData = textscan(fid_s, '%s %s %s %s %s %s %s %s %s %s %s %s','delimiter',',');
    numOfInst = size(rawData{1,1},1) - 1;
    holding = zeros(numOfInst, 3);
    tmp = str2double(rawData{1,1});%ticker
    holding(:,1) = tmp(2:end,1);
    tmp = str2double(rawData{1,4});%holding
    holding(:,2) = tmp(2:end,1) * unit;
    tmp = str2double(rawData{1,5});%available holding
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
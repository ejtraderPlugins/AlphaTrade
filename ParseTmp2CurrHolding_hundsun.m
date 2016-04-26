function ParseTmp2CurrHolding_hundsun(AccountInfo, id)
numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

times = clock;
ndate = times(1) * 1e4 + times(2) * 1e2 + times(3);
sdate = num2str(ndate);

path_log = [AccountInfo{ai}.LOGPATH AccountInfo{ai}.NAME '\'];
path_goal = [AccountInfo{ai}.GOALPATH 'currentHolding\' AccountInfo{ai}.NAME '\'];
path_source = [path_log sdate '\'];
path_dest = [path_goal sdate '\'];
sourceFile = [path_source 'stock_holding.csv'];
destFile = [path_dest 'current_holding.txt'];
unit = str2double(AccountInfo{ai}.UNIT);

%% parse holding log file
fid_s = fopen(sourceFile, 'r');
if fid_s > 0
    rawData = textscan(fid_s, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s','delimiter',',');
    numOfInst = size(rawData{1,1},1) - 2;
    holding = zeros(numOfInst, 3);
    for i = 1:numOfInst
        holding(i,1) = str2double(rawData{1,2}{i+1}(2:end-1));%ticker
        holding(i,2) = str2double(rawData{1,3}{i+1}(2:end-1));%holding
        holding(i,3) = str2double(rawData{1,4}{i+1}(2:end-1));%this day buy vol
        holding(i,3) = (holding(i,2) - holding(i,3)) * unit;% available
    end

    for k = 1:size(holding,2)
        holding(isnan(holding(:,k)),:) = [];
    end
    fclose(fid_s);    
end

if exist(path_dest, 'dir')
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
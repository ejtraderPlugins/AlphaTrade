function ParseTmp2CurrHolding_ims(AccountInfo, id)
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
sourceFile = [path_source 'stock_holding.xls'];
destFile = [path_dest 'current_holding.txt'];
unit = str2double(AccountInfo{ai}.UNIT);

%% parse holding log file
if exist(sourceFile, 'file')
    [~, ~, rawData] = xlsread(sourceFile);
else
    rawData = [];
end
numOfInst = size(rawData,1) - 1;
if numOfInst > 0
    holding = zeros(numOfInst, 3);
    for im = 1:numOfInst
        holding(im,1) = str2double(rawData{im + 1, 2});%ticker
        holding(im,2) = str2double(rawData{im + 1, 6}) * unit;%vol
        holding(im,3) = str2double(rawData{im + 1, 9}) * unit;%available vol
    end
    holding(isnan(holding(:,1)),:) = [];    
end

if exist(destPath,'dir')
else
    mkdir(destPath);
end
if exist('holding','var')
    if ~isempty(holding)
        fid_d = fopen(destFile,'w');
        fprintf(fid_d, [repmat('%15d\t',1,size(holding,2)), '\n'], holding');
        fclose(fid_d);
    end
end
function ParseTmp2CurrHolding_honghui(AccountInfo, id)
global fid_log

numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin to parse stock holding file. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);

dir_server  = ['\\' AccountInfo{ai}.SERVERIP '\Chn_Stocks_Trading_System\AlphaTrade\'];
dir_client  = AccountInfo{ai}.BASEPATH;
dir_client_account = [dir_client AccountInfo{ai}.NAME '\'];
if sum(cell2mat(strfind(AccountInfo{ai}.STRATEGY, 't0')))%如果有t0策略
    dir_current  = [dir_client_account 'CurrentData\T0\'];
else
    dir_current  = [dir_client_account 'CurrentData\Alpha\'];
end
dir_com     = [dir_server 'ComData\'];
dir_dest    = [dir_client_account 'TmpData\'];
dir_history = [dir_client_account 'HistoryData\'];

sourceFile  = [dir_current 'stock_holding.xlsx'];
destFile    = [dir_dest 'current_holding.txt'];
file_split  = [dir_com 'split.txt'];
unit = str2double(AccountInfo{ai}.UNIT);

%% load split files
if exist(file_split, 'file')
	split = load(file_split);
end

%% parse holding log file
if exist(sourceFile, 'file')
    [idate, itime] = GetDateTimeNum();
    fprintf(fid_log, '--->>> %s_%s,\tBegin to parse holding file. file = %s.\n', num2str(idate), num2str(itime), sourceFile);
    
    [~, ~, rawData] = xlsread(sourceFile);
    for i = 1:size(rawData,1)
        for j = 1:size(rawData,2)
            if strcmp(rawData{i,j},' ')
                rawData{i,j} = 0;
            end
        end
    end
                
                
    numOfInst = size(rawData,1) - 1;
    if numOfInst > 0
        holding = zeros(numOfInst, 3);
		holding(:,1) = cellfun(@(x) x, rawData(2:end, 1));%ticker
		holding(:,2) = cellfun(@(x) x, rawData(2:end, 3)) * unit;%vol
		holding(:,3) = cellfun(@(x) x, rawData(2:end, 4));%available vol

        holding(any(isnan(holding),2),:) = [];    
    end
else
    [idate, itime] = GetDateTimeNum();
    fprintf(fid_log, '--->>> %s_%s,\tError when open holding file. file = %s.\n', num2str(idate), num2str(itime), sourceFile);
    fprintf(2, '--->>> %s_%s,\tError when open holding file. file = %s.\n', num2str(idate), num2str(itime), sourceFile);
end

if exist(dir_dest, 'dir')
else
    mkdir(dir_dest);
end
if exist('holding','var')
    if ~isempty(holding)
		if exist('split', 'var')
			[co_ticker, pHolding, pSplit] = intersect(holding(:,1), split(:,1));
			if isempty(co_ticker)
			else
				holding(pHolding,2) = holding(pHolding,2) .* (1 + split(pSplit,2));
			end
		end
        fid_d = fopen(destFile,'w');
        fprintf(fid_d, [repmat('%15d\t',1,size(holding,2)), '\n'], holding');
        fclose(fid_d);
    end
end

%% copy file to history direction
[idate, itime] = GetDateTimeNum();
dst_sourceFile = [dir_history 'HistoricalLog\stock_holding_' num2str(idate) '_' num2str(itime) '.xlsx'];
dst_destFile   = [dir_history 'HistoricalCurrentHolding\current_holding_' num2str(idate) '_' num2str(itime) '.txt'];
dst_file_split = [dir_history 'HistoricalSplit\split_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(sourceFile, dst_sourceFile);
CopyFile2HistoryDir(destFile, dst_destFile);
CopyFile2HistoryDir(file_split, dst_file_split);

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd to parse stock holding file. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
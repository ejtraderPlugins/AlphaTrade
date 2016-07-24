function ParseTmp2CurrHolding_tdx(AccountInfo, id)
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
    dir_current  = [dir_client_account 'CurrentData\t0\'];
else
    dir_current  = [dir_client_account 'CurrentData\alpha\'];
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
fid_s = fopen(sourceFile, 'r');
if fid_s > 0
    [idate, itime] = GetDateTimeNum();
    fprintf(fid_log, '--->>> %s_%s,\tBegin to parse holding file. file = %s.\n', num2str(idate), num2str(itime), sourceFile);
    
    holding = zeros(1000000,3);
    nHolding = 0;
    [~] = fgetl(fid_s);
    [~] = fgetl(fid_s);
    [~] = fgetl(fid_s);
    [~] = fgetl(fid_s);
    while ~feof(fid_s)
        nHolding = nHolding + 1;
        fline = fgetl(fid_s);%rawData = textscan(fid_s, '%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s','delimiter','         ');
        s = strrep(fline, '   ',',');
        d = strfind(s,',');
        p = [];
        for k = 1:length(d)
            p = [p '%s'];
        end
        t = textscan(s, p, 'delimiter',',');
        tmp = zeros(1,3);%3代表着ticker，holding，可用holding，共3个值
        nPiece = size(tmp,2);
        n = 0;%找到这一行中的第几列，用来定位哪一列是想要的数据，例如n == 4，第4列是证券名称，就算不是想要的数据
        m = 0;%一共nPiece个数据，当m == 9 时，表示都找到了，就可以跳出循环了。
        for k = 1:length(t)
            if m >= nPiece
                break;
            end
            if isempty(t{1,k}{1,1})
                continue;
            else
                n = n + 1;
                if n == 1
                    m = m + 1;
                    tmp(1) = str2double(t{1,k});%ticker
                elseif n == 3
                    m = m + 1;
                    tmp(2) = str2double(t{1,k}) * unit;%vol
                elseif n == 4
                    m = m + 1;
                    tmp(3) = str2double(t{1,k}) * unit;%available vol
                end
            end
        end
        holding(nHolding, :) = tmp;
    end
    
    holding(all(holding==0,2),:) = [];
    fclose(fid_s);
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
dst_sourceFile = [dir_history 'HistoricalLog\stock_holding_' num2str(idate) '_' num2str(itime) '.txt'];
dst_destFile   = [dir_history 'HistoricalCurrentHolding\current_holding_' num2str(idate) '_' num2str(itime) '.txt'];
dst_file_split = [dir_history 'HistoricalSplit\split_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(sourceFile, dst_sourceFile);
CopyFile2HistoryDir(destFile, dst_destFile);
CopyFile2HistoryDir(file_split, dst_file_split);
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd to parse stock holding file. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
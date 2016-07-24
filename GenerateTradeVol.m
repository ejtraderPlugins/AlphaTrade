function GenerateTradeVol(AccountInfo, id)
global fid_log
numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tBegin generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);

dir_client         = AccountInfo{ai}.BASEPATH;
dir_server         = ['\\' AccountInfo{ai}.SERVERIP '\Chn_Stocks_Trading_System\AlphaTrade\'];
dir_client_account = [dir_client AccountInfo{ai}.NAME '\'];
dir_server_account = [dir_server AccountInfo{ai}.NAME '\'];
dir_tmpdata        = [dir_client_account 'TmpData\'];
dir_tradefile      = [dir_client_account 'TradeFile\NormalTrade\']
dir_history        = [dir_client_account 'HistoryData\'];

file_target        = [dir_tmpdata 'target_holding.txt'];
file_current       = [dir_tmpdata 'current_holding.txt'];
file_trade         = [dir_tradefile 'trade_holding.txt'];

%% load target file
if exist(file_target, 'file')
    tHolding = load(file_target);
else
    tHolding = 0;
end
%% load current file
if exist(file_current, 'file')
    cHolding = load(file_current);
else
    cHolding = 0;
end
cHolding(all(rem(floor(cHolding(:,1) / 100000), 3) ~= 0, 2),:) = [];
%% generate trade vol, and write into trade file
unionTicker = union(tHolding(:,1), cHolding(:,1));
unionTicker(all(unionTicker == 0, 2), :) = [];
if isempty(unionTicker)
    [idate, itime] = GetDateTimeNum();
    fprintf(2, '--->>> %s_%s,\tError when generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
    fprintf(fid_log, '--->>> %s_%s,\tError when generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
    return;
end
numOfTicker = size(unionTicker,1);
unionHolding = zeros(numOfTicker, 4);%第一列是ticker，第二列是target，第三列是current, 第四列是available
unionHolding(:,1) = unionTicker;
for i = 1:numOfTicker
    pT = find(tHolding(:,1) == unionHolding(i,1), 1, 'first');
    pC = find(cHolding(:,1) == unionHolding(i,1), 1, 'first');
    if isempty(pT)
    unionHolding(i,2) = 0;
    else
        unionHolding(i,2) = tHolding(pT, 2);
    end
    if isempty(pC)
        unionHolding(i,3) = 0;
        unionHolding(i,4) = 0;
    else
        unionHolding(i,3) = cHolding(pC, 2);
        unionHolding(i,4) = cHolding(pC, 3);
    end
end
position = max(unionHolding(:,2), unionHolding(:,3) - unionHolding(:,4));
diffHolding = [unionHolding(:,1), position - unionHolding(:,3)];
fid = fopen(file_trade, 'w');
fprintf(fid, [repmat('%15d\t',1,size(diffHolding,2)), '\n'], diffHolding');
fclose(fid);
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tDONE. Write trade vol file. file = %s.\n', num2str(idate), num2str(itime), file_trade);
dst_file_trade = [dir_history 'HistoricalTrade\trade_holding_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(file_trade, dst_file_trade);
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
fprintf('--->>> %s_%s,\tEnd generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
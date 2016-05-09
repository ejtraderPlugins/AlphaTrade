function GenerateTradeVol_ims(AccountInfo, id)
global fid_log

numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end

%% log
[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\t Begin generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);

path_account = AccountInfo{ai}.ACCOUNTPATH ;

file_target = [path_account 'target_holding.txt'];
file_current = [path_account 'current_holding.txt'];
file_trade = [path_account 'trade_holding.txt'];
file_today = [path_account 'trade_p0.txt'];

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

%% generate trade vol, and write into trade file
unionTicker = union(tHolding(:,1), cHolding(1));
unionTicker(all(unionTicker == 0, 2), :) = [];
numOfTicker = size(unionTicker,1);
unionHolding = zeros(numOfTicker, 3);%第一列是ticker，第二列是target，第三列是current
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
    else
        unionHolding(i,3) = cHolding(pC, 2);
    end
end
diffHolding = [unionHolding(:,1) unionHolding(:,2) - unionHolding(:,3)];

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\tWrite trade vol file. file = %s.\n', num2str(idate), num2str(itime), file_trade);
fid = fopen(file_trade, 'w');
fprintf(fid, [repmat('%15d\t',1,size(diffHolding,2)), '\n'], diffHolding');
fclose(fid);

dst_file_trade = [path_account '\HistoricalTrade\trade_holding_' num2str(idate) '_' num2str(itime) '.txt'];
CopyFile2HistoryDir(file_trade, dst_file_trade);


%% write into trade files for client
diffHolding(all(diffHolding(:,2) == 0,2), :) = [];
numOfTrade = size(diffHolding,1);
fid = fopen(file_today, 'w');
if fid > 0
    PriceType = 'ANY';
    Price = '0';
    for i = 1:numOfTrade
        if diffHolding(i,1) < 600000
            Market = '1';
        else
            Market = '0';
        end
        Ticker = num2str(diffHolding(i,1), '%06d');
        if diffHolding(i,2) > 0
            BS = 'B';
        elseif diffHolding(i,2) < 0
            BS = 'S';
        end
        Vol = num2str(abs(diffHolding(i,2)));
        
        lines = [Market '|' Ticker '|' BS '|' '|' PriceType '|' Price '|' Vol '\n'];
        fprintf(fid, lines);
    end
    fclose(fid);
    
    [idate, itime] = GetDateTimeNum();
    fprintf(fid_log, '--->>> %s_%s,\tDone write trade file. file = %s.\n', num2str(idate), num2str(itime), file_today);
    dst_file_today = [path_account '\HistoricalTrade\trade_p0_' num2str(idate) '_' num2str(itime) '.txt'];
    CopyFile2HistoryDir(file_today, dst_file_today);   
else
    fprintf(fid_log, '--->>> %s_%s,\tError when write trade file. file = %s.\n', num2str(idate), num2str(itime), file_today);
    fclose(fid);
    return;
end

[idate, itime] = GetDateTimeNum();
fprintf(fid_log, '--->>> %s_%s,\t End generate trade vol. account = %s.\n', num2str(idate), num2str(itime), AccountInfo{ai}.NAME);
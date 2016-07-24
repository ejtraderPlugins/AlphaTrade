function [sell_size, buy_size] = CheckDiff(AccountInfo,id,w_stockPrice)
sell_size = 0;
buy_size = 0;
numOfAccount = length(AccountInfo);
for ai = 1:numOfAccount
    if str2double(AccountInfo{ai}.ID) == id
        break;
    end
end
dir_client         = AccountInfo{ai}.BASEPATH;
dir_client_account = [dir_client AccountInfo{ai}.NAME '\'];
dir_tmpdata        = [dir_client_account 'TmpData\'];
file_trade         = [dir_tmpdata 'trade_holding.txt'];

%%load trade_holding
[idate, itime] = GetDateTimeNum();
if exist(file_trade, 'file')
    tmpTrade = load(file_trade);
    col = size(tmpTrade,1);    
else
    fprintf(fid_log, '--->>> %s_%s,\tError func = CheckDiff, not exist trade_holding.txt, error = not exsit trade_holding.txt\n', num2str(idate), num2str(itime));
    fprintf(2, '--->>> %s_%s,\tError func = CheckDiff, not exist trade_holding.txt, error = not exsit trade_holding.txt\n', num2str(idate), num2str(itime));
    return;
end
if col > 0
    for i = 1:col
        Pt = find(w_stockPrice(:,3) == tmpTrade(i,1));
        if isempty(Pt)
            fprintf(fid_log, '--->>> %s_%s,\tError func = CheckDiff, not exist ticker in stockPrice. error = ticker(%d)\n', num2str(idate), num2str(itime), tmpTrade(i,1));
            fprintf(2, '--->>> %s_%s,\tError func = CheckDiff, not exist ticker in stockPrice. error = ticker(%d)\n', num2str(idate), num2str(itime), tmpTrade(i,1));
            continue;
        end
        if tmpTrade(i,2) == 0
        elseif tmpTrade(i,2) > 0
            buy_size = buy_size + w_stockPrice(Pt,1) * tmpTrade(i,2);
        else
            sell_size = sell_size +  w_stockPrice(Pt,1) * tmpTrade(i,2);
        end
    end
else
    fprintf(fid_log, '--->>> %s_%s,\tError func = CheckDiff, nothing in trade_holding.txt, error = nothing in trade_holding.txt\n', num2str(idate), num2str(itime));
    fprintf(2, '--->>> %s_%s,\tError func = CheckDiff, nothing in trade_holding.txt, error = nothing in trade_holding.txt\n', num2str(idate), num2str(itime));
    return;
end